# Flutter mobile client

## Setup

```bash
flutter pub get
flutter analyze
flutter test
```

Run with an API URL that is reachable from the target device:

```bash
# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api

# iOS simulator / web / desktop on the same host
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
```

For a physical device, use the development computer's LAN IP instead of `localhost` and ensure the device can reach the backend.

The client stores the access token using `flutter_secure_storage`. Authenticated API requests attach a Bearer token. The Dart SDK constraint is declared in `pubspec.yaml`.

No Flutter SDK was available in the package-preparation environment, so analysis, tests and platform builds remain unverified.
