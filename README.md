BayanSense: A Barangay Concern Reporting System

Summary

BayanSense is a Flutter-based web and mobile application designed to help residents report community infrastructure concerns within their barangay, including flooding, drainage problems, sewer issues, and water-waste concerns. Its initial features focus on resident registration and login, submitting reports in Bisaya, Tagalog, or English, viewing backend classification results, and tracking submitted reports.

Current stack

Flutter Web / Android / Dart for the frontend; a REST API backend for authentication, report submission, classification, and report tracking; PostgreSQL for the planned database.

Run with the real backend

```powershell
Set-Location backend
uvicorn app.main:app --reload
```

In a second terminal:

```powershell
Set-Location frontend
flutter pub get
flutter run -d chrome
```

The web default API URL is `http://127.0.0.1:8000`. Change it in one place with:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

For an Android emulator, use `--dart-define=API_BASE_URL=http://10.0.2.2:8000`.

To switch to in-memory demo data:

```powershell
flutter run -d chrome --dart-define=USE_MOCK=true
```

`USE_MOCK` defaults to `false`; tokens are stored using the existing
`shared_preferences` implementation. Photo attachments are unavailable until the
backend provides an upload endpoint. Status history and active staff statistics
also have no API endpoints.
