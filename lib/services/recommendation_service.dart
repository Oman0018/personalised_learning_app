// lib/services/recommendation_service.dart
//personalised_learning_app/lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RecommendationService {
  static Future<Map<String, dynamic>> getRecommendation({
    required int quizScore,
    required int timeSpent,
    required String contentType,
    required int engagement,
  }) async {
    // ✅ MOCK MODE: fast, reliable response for demos
    if (kUseMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'recommendation': <String>[
          'Watch video lessons on Advanced Flutter Widgets',
          'Attempt at least 2 quizzes this week',
          'Spend ~20 extra minutes on practice exercises',
        ],
      };
    }

    // 🔗 LIVE MODE (when kUseMock = false)
    final url = Uri.parse('$kBaseUrl/recommend');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'quiz_score': quizScore,
      'time_spent': timeSpent,
      'content_type': contentType,
      'topic_engagement': engagement,
    });

    final res = await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 8));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get recommendation: ${res.statusCode}');
  }
}
