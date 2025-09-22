// lib/env.dart
class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Real device + `adb reverse tcp:8000 tcp:8000`
    defaultValue: 'http://127.0.0.1:8000',
  );
}
