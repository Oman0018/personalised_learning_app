//lib/services/mock_data.dart
class MockData {
  // ---- Recommendations (used by RecommendationsScreen) ----
  static Map<String, dynamic> getRecommendation({
    required int quizScore,
    required int timeSpent,
    required String contentType,
    required int engagement,
  }) {
    return {
      'recommended_topics': [
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
      ],
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
