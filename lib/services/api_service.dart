import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> sendRecommendationRequest(
    double quizScore,
    double timeSpent,
    int contentTypePref,
    int engagement,
  ) async {
    const String apiUrl = 'http://127.0.0.1:5000/recommend';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "avg_quiz_score": quizScore,
        "avg_time_spent": timeSpent,
        "content_type_pref": contentTypePref,
        "topic_engagement": engagement
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return 'Recommended Topic: ${data['recommended_topic']}\nCluster: ${data['user_cluster']}';
    } else {
      return 'Failed to get recommendation. Please check your input and server.';
    }
  }
}
