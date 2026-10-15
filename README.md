BayanSense: A Barangay Concern Reporting System

Summary

BayanSense is a Flutter-based web and mobile application designed to help residents report community infrastructure concerns within their barangay, including flooding, drainage problems, sewer issues, and water-waste concerns. Its initial features focus on resident registration and login, submitting reports in Bisaya, Tagalog, or English, viewing backend classification results, and tracking submitted reports.

Current stack

Flutter Web / Android / Dart for the frontend; a REST API backend for authentication, report submission, classification, and report tracking; PostgreSQL for the planned database.

Run locally

bash
flutter pub get
flutter run -d chrome


If your backend requires a specific API URL, configure it when running the app:

bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:57945/


Make sure the backend is running before testing features that require API access.

First checkpoint

Date: __________    Commit: __________