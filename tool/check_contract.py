#!/usr/bin/env python3
"""
Checks the Flutter app against the backend's OpenAPI spec, without running either one.

For every API call in lib/services/api_client.dart it verifies that:
  - the URL path and HTTP method exist in the backend
  - every field the app SENDS exists in the request schema, and every REQUIRED field is sent
  - every field the app READS (in lib/models/*.dart and api_client.dart) exists in the response schema

Usage (backend running):   python tool/check_contract.py
Or from a saved file:      python tool/check_contract.py --openapi path/to/openapi.json
Exit code is 1 if anything does not match, so it can run in CI.
"""
import argparse
import json
import os
import re
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)

# Dart model class -> the backend response schema it is parsed from.
MODELS = {
    "Session": "LoginResponse",
    "Report": "ReportDetailResponse",
    "SubmissionResult": "ReportCreateResponse",
}


def load_openapi(source):
    if source.startswith(("http://", "https://")):
        with urllib.request.urlopen(source, timeout=10) as r:
            return json.load(r)
    with open(source, encoding="utf-8") as f:
        return json.load(f)


def resolve(spec, schema):
    """Follow $ref; for arrays, look at the item type."""
    if not schema:
        return {}
    if "$ref" in schema:
        return resolve(spec, spec["components"]["schemas"][schema["$ref"].split("/")[-1]])
    if schema.get("type") == "array":
        return resolve(spec, schema.get("items", {}))
    return schema


def body_schema(spec, content):
    return resolve(spec, ((content or {}).get("application/json") or {}).get("schema"))


def normalize_path(path):
    return re.sub(r"\{[^}]*\}", "{}", path)


def dart_path_to_template(path):
    return re.sub(r"\$\{[^}]*\}|\$\w+", "{}", path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--openapi", default="http://localhost:8000/openapi.json")
    args = parser.parse_args()
    try:
        spec = load_openapi(args.openapi)
    except Exception as exc:
        print(f"Could not load the OpenAPI spec from {args.openapi}: {exc}")
        print("Start the backend first, or pass --openapi path/to/openapi.json")
        return 2

    problems, notes = [], []
    ok_lines = []

    # ---- 1. models: keys read in fromJson vs response schema ----
    for cls, schema_name in MODELS.items():
        found = None
        for fn in sorted(os.listdir(os.path.join(APP, "lib", "models"))):
            text = open(os.path.join(APP, "lib", "models", fn), encoding="utf-8").read()
            m = re.search(r"class\s+" + cls + r"\b.*?factory\s+" + cls + r"\.fromJson\((.*?)\);\s*\n", text, re.S)
            if m:
                found = (fn, m.group(0))
                break
        if not found:
            problems.append(f"model {cls}: factory {cls}.fromJson not found")
            continue
        fn, block = found
        read = set(re.findall(r"json\['(\w+)'\]", block))
        props = set(spec["components"]["schemas"][schema_name].get("properties", {}))
        unknown = sorted(read - props)
        unread = sorted(props - read)
        if unknown:
            problems.append(f"lib/models/{fn}: {cls} reads {unknown}, which {schema_name} does not have")
        else:
            ok_lines.append(f"model {cls:<17} reads {len(read)} fields, all present in {schema_name}")
        if unread:
            notes.append(f"{cls} ignores fields the server sends: {unread}")

    # ---- 2. api_client endpoints ----
    text = open(os.path.join(APP, "lib", "services", "api_client.dart"), encoding="utf-8").read()
    endpoints_part = text.split("// ---------------- plumbing")[0]
    chunks = re.split(r"\n  Future<", endpoints_part)[1:]
    used = set()
    for chunk in chunks:
        name = re.match(r"[\w<>?, ]+?>\s+(\w+)\(", chunk) or re.match(r"[^\s(]+\s+(\w+)\(", chunk)
        label = name.group(1) if name else "?"
        call = re.search(r"_request\(\s*'(GET|POST|PATCH|PUT|DELETE)',\s*'([^']+)'", chunk)
        if not call:
            problems.append(f"api_client.dart {label}(): no _request(...) call found")
            continue
        method, dart_path = call.group(1).lower(), call.group(2)
        template = dart_path_to_template(dart_path)
        match = [p for p in spec["paths"] if normalize_path(p) == template and method in spec["paths"][p]]
        if not match:
            problems.append(f"api_client.dart {label}(): {method.upper()} {dart_path} does not exist in the backend")
            continue
        op = spec["paths"][match[0]][method]
        used.add((method, match[0]))

        # request fields
        sent = set()
        mbody = re.search(r"body:\s*\{([^}]*)\}", chunk)
        if mbody:
            sent = set(re.findall(r"'(\w+)'\s*:", mbody.group(1)))
        req = body_schema(spec, (op.get("requestBody") or {}).get("content"))
        req_props, req_required = set(req.get("properties", {})), set(req.get("required", []))
        bad = sorted(sent - req_props)
        missing = sorted(req_required - sent)
        if bad:
            problems.append(f"api_client.dart {label}(): sends {bad}, which {method.upper()} {match[0]} does not accept")
        if missing:
            problems.append(f"api_client.dart {label}(): does not send required field(s) {missing} for {method.upper()} {match[0]}")

        # response fields read directly in this method (models are checked above)
        read = set(re.findall(r"json\['(\w+)'\]", chunk))
        ok_status = next((c for c in op["responses"] if c.startswith("2")), None)
        resp = body_schema(spec, op["responses"].get(ok_status, {}).get("content")) if ok_status else {}
        resp_props = set(resp.get("properties", {}))
        bad = sorted(read - resp_props)
        if bad:
            problems.append(f"api_client.dart {label}(): reads {bad}, which the {ok_status} response of {method.upper()} {match[0]} does not have")
        if not (bad or missing or sent - req_props):
            ok_lines.append(f"call {label + '()':<16} {method.upper():<5} {match[0]:<26} request/response fields match")

    all_ops = {(m, p) for p, ops in spec["paths"].items() for m in ops if m in ("get", "post", "put", "patch", "delete")}
    unused = sorted(all_ops - used)
    if unused:
        notes.append("backend endpoints the app does not call yet: " + ", ".join(f"{m.upper()} {p}" for m, p in unused))

    for line in ok_lines:
        print("OK       ", line)
    for line in notes:
        print("note     ", line)
    for line in problems:
        print("MISMATCH ", line)
    print(f"\n{len(problems)} mismatch(es)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
