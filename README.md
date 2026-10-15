BayanSense Frontend

BayanSense is a Flutter frontend for reporting barangay flooding, drainage, sewer, water-waste, and related infrastructure concerns. It runs on Web and Android and connects to the BayanSense backend for account access, report submission, classification, and report tracking.

The current release focuses on the resident experience:

Register and log in to a resident account.
Describe a concern in Bisaya, Tagalog, or English and submit it for the backend to review.
See the decision returned by the backend, including a confirmation or an out-of-scope notice.
View submitted reports, their current status, and report details.

This frontend does not currently support photo uploads or automatic location capture. Staff and administrator screens are placeholders; they are not part of the resident workflow yet. BayanSense is not an emergency or medical service.

Validation Status

The source was written without a Flutter SDK available, so it has not yet been compiled or run.

The following checks were completed:

Every file parses as valid Dart using a Dart parser. A cross-file check found no missing imports, misspelled named arguments, or misspelled static members.
`tool/check_contract.py` confirms every URL, request field, and response field matches the backend's real OpenAPI specification, with zero mismatches.
`test/widget_test.dart` was written against real responses captured from the running backend.

Compilation, test execution, and the appearance of the screens have not yet been verified. Run `flutter analyze` and `flutter test` after setup to check the project in a Flutter environment.

Setup (Once)

Install Flutter using the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).

Then, from this `frontend/` folder, run:

bash
flutter create --project-name bayansense_app --platforms=web,android .
flutter pub get
flutter analyze


The `flutter create` command adds or configures the Web and Android platform files. Do not use `--overwrite`, because you should preserve your existing application files, including `lib/`, `pubspec.yaml`, and `test/widget_test.dart`.

Run It

1. Start the backend and create an admin account. See `backend/README.md` for instructions.
2. Keep `CORS_ORIGINS=*` in `backend/.env` during local development, if that matches your backend configuration.
3. Run the Flutter Web app:

bash
flutter run -d chrome --dart-define=API_BASE_URL=http://

Android Emulator

Use this API URL for an Android emulator:

bash
--dart-define=API_BASE_URL=http://10.0.2.2:8000


The address `10.0.2.2` allows the Android emulator to reach the host computer.

In `android/app/src/main/AndroidManifest.xml`, add the following permission above the `<application>` element if it is not already present:

xml
<uses-permission android:name="android.permission.INTERNET"/>


For local development over plain HTTP, add android:usesCleartextTraffic="true" to the <application> element if required by your Android configuration.

These Android settings have not yet been tested in this project. Use HTTPS for deployed builds.

First-Run Checklist

Register a resident account, then submit the following sample reports. The expected results come from the backend's placeholder classifier** and may change when the trained model replaces it.

| Sample input | Expected result |
|||
| `Baha sa kalsada, binaha ang buong purok kagabi` | Confirmation showing Flooding, routed to BDRRM, without a review message |
| `Napakaingay ng kapitbahay namin tuwing gabi` | Confirmation indicating that staff will decide, with a message that staff will double-check |
| `Kailangan ng doktor ang anak ko, may sakit siya` | The "Not handled by BayanSense" screen |
| `too short` | "Please describe the concern in more detail." The app should block submission without sending a request |

Next, open My Reports, select a report, and log out. Confirm that entering `/#/resident/home` in the browser address bar redirects you to the login screen when you are signed out.

Testing a Staff Account

1. Log in to the backend's [Swagger UI](http://localhost:8000/docs) as an admin.
2. Use `POST /admin/personnel` to create a staff account.
3. Log in to the Flutter app using that account.

The expected result is a "Coming soon" screen rather than the resident home screen.

Project Structure

text
lib/
  main.dart, app.dart
    Application startup, providers, and theme
  config.dart
    API_BASE_URL configuration
  routing/
    Route paths, access guards, and route table
  services/
    ApiClient, TokenStore, and ApiException
  state/
    AuthState and ReportsState
  models/
    Session, Report, and SubmissionResult
  screens/
    Login, home, report submission, report details,
    report history, staff placeholders, and error screens
  widgets/
    AppButton, AppTextField, StatusChip, StatusMessage,
    ReportCard, and other reusable components
  validators.dart
  error_messages.dart
  format.dart

test/
  widget_test.dart
    Tests for API client, state, validators, and routes

tool/
  check_contract.py
    Checks the frontend/backend API contract


Run the API contract check whenever the backend API changes. The backend must be running:

bash
python tool/check_contract.py


Differences from the Activity 6 and 7 Documents

Decide whether to update the documentation or the code to keep them consistent.

1. No `go_router`: The app uses Navigator named routes with paths such as `/resident/home`. On the Web, the URL uses hash-based routing, such as `/#/resident/home`, which supports static hosting without server rewrite rules.

2. Login storage uses `shared_preferences`:** The app does not use `flutter_secure_storage` as described in Activity 3. This approach supports Web and mobile but does not provide encrypted storage by itself. Revisit the storage approach before real deployment.

3. No photo or location submission yet:** The current API does not provide a photo-upload endpoint. The `image_url` field is only text, and the app does not submit coordinates. Residents should include the location in their report description. Photo uploads require backend support and file storage; location features require platform permissions and implementation.

4. My Reports uses a single-column list: It does not use the two-column grid described in Activity 6, Part D.

5. Dates display only the day: The server stores timestamps without a time zone, so displaying a clock time could be inaccurate. Proper handling requires a backend change, such as storing timestamps in UTC.

6. Reference numbers: Identifiers such as `BS-0007` are the report ID padded with leading zeros.

7. Staff screens are placeholders: The department dashboard and admin screens remain planned for Phase 2.


Repository: `tengson_bayansense`

Reference commit:`3c207ae49c1aa46efd6f798bfd700f0cec2b11a2`