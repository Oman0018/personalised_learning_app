// lib/services/mock_data.dart
class MockData {
  /// Unified mock response that mirrors the live /recommend API
  /// PLUS a richer 'recommended_topics' list for card views.
  static Map<String, dynamic> getRecommendation({
    required int quizScore,
    required int timeSpent,
    required String contentType, // 'Video' | 'Text' | 'Interactive'
    required int engagement,     // 1..5
  }) {
    // Derive a single headline topic like the live backend
    final String headlineTopic = () {
      if (quizScore >= 75) return 'Data Science';
      if (quizScore >= 60) return 'Control Flow & Loops';
      return 'Foundations';
    }();

    // Fake a cluster (deterministic-ish): 0..2
    final int cluster = ((quizScore ~/ 10) + engagement) % 3;

    // Normalize content label
    final String typeLower = contentType.toLowerCase();

    // The simple string list your HomeScreen expects
    final List<String> flatRecommendations = <String>[
      'Focus on $headlineTopic ($typeLower)',
      'Attempt at least 2 quizzes this week',
      'Spend ~20 extra minutes on practice exercises',
      'You are in cohort/cluster $cluster',
    ];

    // Rich cards list that other screens can render
    final List<Map<String, String>> topicCards = <Map<String, String>>[
      {
        'title': 'Introduction to Machine Learning',
        'level': quizScore < 60 ? 'Beginner' : 'Intermediate',
        'duration': '${30 + (engagement * 5)} mins',
      },
      {
        'title': contentType == 'Video'
            ? 'Neural Networks (Video Walkthrough)'
            : 'Neural Networks (Reading)',
        'level': engagement >= 4 ? 'Intermediate' : 'Beginner',
        'duration': '${35 + timeSpent ~/ 4} mins',
      },
      {
        'title': 'Hands-on Data Visualization',
        'level': 'Intermediate',
        'duration': '40 mins',
      },
    ];

    return {
      // --- keys that mirror the live /recommend response ---
      'recommended_topic': headlineTopic,
      'user_cluster': cluster,
      'status': 'success',
      'recommendation': flatRecommendations,

      // --- extra mock-only detail for other screens ---
      'recommended_topics': topicCards,
    };
  }

  // ---- Learning Modules (used by LearningModuleScreen) ----
  static final List<Map<String, String>> modules = [
    {
      'id': 'm1',
      'title': 'Introduction to AI',
      'summary': 'What is AI? History, scope, and applications.',
      'content':
          'Artificial Intelligence (AI) is the simulation of human intelligence in machines.\n\n'
          '• Narrow vs General AI\n• Symbolic AI vs ML\n• Real-world examples',
    },
    {
      'id': 'm2',
      'title': 'Supervised Learning',
      'summary': 'Regression, classification, and evaluation.',
      'content':
          'Supervised learning uses labeled data to learn mappings from inputs to outputs.\n\n'
          '• Regression vs Classification\n• Loss & metrics\n• Train/Val/Test splits',
    },
    {
      'id': 'm3',
      'title': 'Neural Networks Basics',
      'summary': 'Neurons, layers, and activations.',
      'content':
          'Neural networks are compositions of linear and non-linear transforms.\n\n'
          '• Perceptron\n• ReLU, Sigmoid, Tanh\n• Backpropagation (intuition)',
    },
  ];
}
