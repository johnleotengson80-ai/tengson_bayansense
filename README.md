# BayanSense app (Flutter: web + Android)

**Phase 1 = the resident flow:** register / log in, submit a report, see what the system decided,
and track your reports. Staff screens (department dashboard, status updates, admin) are Phase 2;
the backend already supports them.

## Read this first: this code has not been compiled yet

It was written in a sandbox with no Flutter SDK (Google's servers are blocked there). What *was* checked:

- every file parses as valid Dart (a Dart parser), and a cross-file check found no missing imports,
  misspelled named arguments, or misspelled static members
- `tool/check_contract.py` confirms every URL, request field, and response field matches the backend's
  real OpenAPI spec (0 mismatches)
- `test/widget_test.dart` was written against real responses captured from the running backend

What was **not** checked: whether it compiles (types, null safety), whether the tests pass, and how any screen
looks. Your first run is the real test. If `flutter analyze` or `flutter test` prints anything, send it to me
and I will fix it.

## Setup (once)

Install Flutter (https://docs.flutter.dev/get-started/install), then from this `frontend/` folder:

```bash
flutter create --project-name bayansense_app --platforms=web,android .
flutter pub get
flutter analyze
flutter test
```

`flutter create .` adds the `web/` and `android/` folders. It does not overwrite files that already exist
(`lib/`, `pubspec.yaml`, `test/widget_test.dart`) unless you pass `--overwrite`; do not.

## Run it

1. Start the backend and create an Admin (see `backend/README.md`). Keep `CORS_ORIGINS=*` in `backend/.env` while developing.
2. Then:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

**Android emulator:** use `--dart-define=API_BASE_URL=http://10.0.2.2:8000` (10.0.2.2 is how the emulator reaches your computer).
In `android/app/src/main/AndroidManifest.xml`, add `<uses-permission android:name="android.permission.INTERNET"/>`
above `<application`, and for development over plain `http://` add `android:usesCleartextTraffic="true"` inside the
`<application ...>` tag. (Standard Flutter/Android setup; not tried here. Use HTTPS in any deployed build.)

## First-run checklist

Register a resident, then submit these. The expected results come from the backend's **placeholder** classifier
and will change when the trained model replaces it:

| You type | You should see |
|---|---|
| `Baha sa kalsada, binaha ang buong purok kagabi` | Confirmation: Flooding, sent to BDRRM, no review message |
| `Napakaingay ng kapitbahay namin tuwing gabi` | Confirmation: "Staff will decide" and a staff-will-double-check message |
| `Kailangan ng doktor ang anak ko, may sakit siya` | The "not handled by BayanSense" screen |
| `too short` | "Please describe the concern in more detail." (blocked on the phone, no request sent) |

Then open **My reports**, tap a report, log out, and confirm that typing `/#/resident/home` in the address bar sends you to login.
To test a staff login, log in to http://localhost:8000/docs as the Admin, use `POST /admin/personnel` to create a staff account, then log in with it in the app: you should land on a "Coming soon" screen, not a resident screen.

## What is where

```
lib/
  main.dart, app.dart        start-up, providers, theme
  config.dart                API_BASE_URL
  routing/                   route paths, access guards, route table
  services/                  ApiClient (all HTTP), TokenStore (saved login), ApiException
  state/                     AuthState (who is signed in), ReportsState (my reports, submitting)
  models/                    Session, Report, SubmissionResult
  screens/                   one file per screen (S01-S05, S09, detail, staff placeholder, not found)
  widgets/                   AppButton, AppTextField, StatusChip, StatusMessage, ReportCard, ...
  validators.dart, error_messages.dart, format.dart
test/widget_test.dart        logic tests (API client, state, validators, routes) using real captured responses
tool/check_contract.py       app <-> backend contract check
```

Re-run the contract check whenever the backend API changes (backend running):
`python tool/check_contract.py`

## Differences from the Activity 6 / 7 documents (decide whether to update the docs or the code)

1. **No go_router.** Navigator named routes with the same paths (`/resident/home`, ...). Fewer dependencies and a
   more stable API. On web the address uses `#/` (`.../#/resident/home`), which works on static hosting with no
   server rewrite rules.
2. **Login is saved with `shared_preferences`, not `flutter_secure_storage`** (Activity 3). It is simple and works on
   web and mobile, but it is not encrypted storage. Revisit before real deployment.
3. **Submit Report has no photo or location yet.** The API has no upload endpoint (`image_url` is just a text field)
   and the app does not send coordinates. Residents are asked to include the place in the description. Photo upload needs
   a backend endpoint and file storage first; location needs a platform permission setup.
4. **My Reports is a single-column list**, not the two-column grid in Activity 6 Part D.
5. **Dates show the day only.** The server stores timestamps without a time zone, so a clock time could be wrong
   for the resident. Fixing it properly is a backend change (store UTC).
6. **Reference numbers** like `BS-0007` are just the report id, zero-padded.
7. **Staff screens are placeholders** (department dashboard, admin) until Phase 2.
