class RecommendationInput {
  final int quizScore;
  final int timeSpent;
  final int engagement;
  final String contentType;

  const RecommendationInput({
    required this.quizScore,
    required this.timeSpent,
    required this.engagement,
    required this.contentType,
  });

  Map<String, dynamic> toJson() => {
    'quiz_score': quizScore,
    'time_spent': timeSpent,
    'topic_engagement': engagement,
    'content_type': contentType,
  };
}
