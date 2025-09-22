// lib/config/app_config.dart
import '../env.dart';

/// When true, the app fakes backend calls.
const bool kUseMock = false;

/// Show the developer quick-jump button.
const bool kShowDevJump = true;

/// Single source of truth for the API URL (comes from Env).
const String kBaseUrl = Env.apiBaseUrl;
