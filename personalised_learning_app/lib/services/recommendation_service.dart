// lib/services/recommendation_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

import '../config/app_config.dart'; // kUseMock, kBaseUrl

// If you're on the Android emulator, run with:
// flutter run --dart-define=USE_ANDROID_EMULATOR=true
const bool _useAndroidEmulator =
    bool.fromEnvironment('USE_ANDROID_EMULATOR', defaultValue: false);

class RecommendationService {
  /// Decide the base URL:
  /// 1) Use kBaseUrl if provided (recommended via --dart-define API_BASE_URL=...).
  /// 2) Otherwise pick a sane default per platform.
  static String get _base {
    // Highest priority: compile-time define from Env/api_config → kBaseUrl
    if (kBaseUrl.isNotEmpty) return kBaseUrl;

    // Fallbacks
    if (!kIsWeb && Platform.isAndroid) {
      // Real device with `adb reverse tcp:8000 tcp:8000` -> 127.0.0.1
      // Android emulator (no reverse) -> 10.0.2.2
      final host = _useAndroidEmulator ? '10.0.2.2' : '127.0.0.1';
      return 'http://$host:8000';
    }

    // iOS simulator / desktop / web dev
    return 'http://127.0.0.1:8000';
  }

  static Uri _uri(String path) => Uri.parse('$_base$path');

  static Future<Map<String, dynamic>> getRecommendation({
    required int quizScore,
    required int timeSpent,
    required String contentType, // 'Video' | 'Text' | 'Interactive'
    required int engagement, // 1..5 from the UI
  }) async {
    // ---------------- MOCK MODE ----------------
    if (kUseMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final lcType = contentType.toLowerCase();
      return {
        'recommended_topic': 'Data Science (mock)',
        'user_cluster': 2,
        'status': 'success',
        'recommendation': <String>[
          'Focus on Data Science ($lcType)',
          'Attempt at least 2 quizzes this week',
          'Spend ~20 extra minutes on practice exercises',
          'You are in cohort/cluster 2',
        ],
      };
    }

    // ---------------- LIVE MODE ----------------
    final engagement01 = (engagement.clamp(0, 5).toDouble()) / 5.0;
    final url = _uri('/recommend');
    final body = {
      'avg_quiz_score': quizScore,
      'avg_time_spent': timeSpent,
      // Backend lower-cases internally, but send lower-case to be safe:
      'content_type_pref': contentType.toLowerCase(),
      'topic_engagement': engagement01, // 0..1
    };

    debugPrint('[REC] POST $url');
    debugPrint('[REC] body: $body');

    http.Response res;
    try {
      res = await http
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw Exception(
        'Request timed out. Is the backend running and reachable at $_base?',
      );
    } on Exception catch (e) {
      throw Exception('Network error: $e');
    }

    debugPrint('[REC] <-- ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      // Show server error back to the UI
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final topic = (data['recommended_topic'] ?? 'Unknown').toString();
    final cluster = (data['user_cluster'] as num?)?.toInt();

    final derived = <String>[
      'Focus on $topic (${contentType.toLowerCase()})',
      'Attempt at least 2 quizzes this week',
      'Spend ~20 extra minutes on practice exercises',
      if (cluster != null) 'You are in cohort/cluster $cluster',
    ];

    return {
      ...data, // recommended_topic, user_cluster, status
      'recommendation': derived,
    };
  }
}
