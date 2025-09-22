// lib/state/quiz_data.dart

class QuizResults {
  static final QuizResults _instance = QuizResults._internal();
  factory QuizResults() => _instance;
  QuizResults._internal();

  String? learningStyle;
  double skillLevel = 5;
  List<String> interests = [];

  void reset() {
    learningStyle = null;
    skillLevel = 5;
    interests = [];
  }

  @override
  String toString() {
    return 'Style: $learningStyle, Skill: $skillLevel, Interests: $interests';
  }
}
