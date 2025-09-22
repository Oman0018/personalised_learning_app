// personalised_learning_app/lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../config/app_config.dart';

class ApiService {
  // Prefer explicit base from config (kBaseUrl); otherwise choose per-platform.
  // Android emulator cannot reach 127.0.0.1 on the host; use 10.0.2.2 there.
  static String get _base {
    if (kBaseUrl.isNotEmpty) return kBaseUrl;
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:8000';
  }

  static Uri _uri(String path) => Uri.parse('$_base$path');

  /// --- v1: POST /recommend (kept for backward compatibility) ---
  /// contentTypePref: 0=video, 1=text, 2=interactive
  /// engagement: 1..5 from UI (we normalize to 0..1)
  static Future<Map<String, dynamic>> recommend({
    required double quizScore,
    required double timeSpent,
    required int contentTypePref,
    required int engagement,
  }) async {
    final payload = {
      'avg_quiz_score': quizScore,
      'avg_time_spent': timeSpent,
      'content_type_pref':
          {0: 'video', 1: 'text', 2: 'interactive'}[contentTypePref] ?? 'video',
      'topic_engagement': (engagement.clamp(0, 5).toDouble()) / 5.0,
    };

    final url = _uri('/recommend');
    debugPrint('[API] POST $url');
    debugPrint('[API] body: $payload');

    final r = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('[API] <-- ${r.statusCode} ${r.body}');
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// --- v2: POST /recommend/v2 (preferred) ---
  /// Same inputs as v1 + optional lastTopic; returns topic, content_type, cluster, rationale, gemini_note
  static Future<Map<String, dynamic>> recommendV2({
    required double quizScore,
    required double timeSpent,
    required int contentTypePref,
    required int engagement,
    String lastTopic = 'Foundations',
  }) async {
    final payload = {
      'avg_quiz_score': quizScore,
      'avg_time_spent': timeSpent,
      'content_type_pref':
          {0: 'video', 1: 'text', 2: 'interactive'}[contentTypePref] ?? 'video',
      'topic_engagement': (engagement.clamp(0, 5).toDouble()) / 5.0,
      'last_topic': lastTopic,
    };

    final url = _uri('/recommend/v2');
    debugPrint('[API] POST $url');
    debugPrint('[API] body: $payload');

    final r = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('[API] <-- ${r.statusCode} ${r.body}');
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// Optional: quick GET /health
  static Future<bool> health() async {
    try {
      final r = await http.get(_uri('/health'));
      debugPrint('[API] GET /health -> ${r.statusCode}');
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Expose base for a small banner/debug
  static String get base => _base;
}
