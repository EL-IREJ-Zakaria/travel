# Travell

Flutter frontend + Dart backend for destination/flight data.

## Run Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Default backend URL: `http://localhost:8080`

## Run Flutter App

```bash
flutter pub get
flutter run
```

Optional override for API URL:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```
