//personalised_learning_app/lib/services/feedback_service.dart
import 'dart:async';

class FeedbackService {
  static Future<List<Map<String, String>>> submit({
    required int rating,
    required bool tooEasy,
    required bool tooHard,
    required String comments,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (tooEasy) {
      return [
        {'title': 'Advanced CNN Architectures', 'level': 'Advanced', 'duration': '50 mins'},
        {'title': 'Optimization & Regularization', 'level': 'Advanced', 'duration': '45 mins'},
      ];
    } else if (tooHard) {
      return [
        {'title': 'Linear Models Refresher', 'level': 'Beginner', 'duration': '30 mins'},
        {'title': 'Evaluation Metrics Basics', 'level': 'Beginner', 'duration': '35 mins'},
      ];
    } else {
      return [
        {'title': 'Feature Engineering Workshop', 'level': 'Intermediate', 'duration': '40 mins'},
        {'title': 'Model Debugging Tips', 'level': 'Intermediate', 'duration': '35 mins'},
      ];
    }
  }
}
