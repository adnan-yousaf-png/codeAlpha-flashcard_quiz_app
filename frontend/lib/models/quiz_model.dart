class QuizQuestion {
  final int id;
  final String question;
  final String category;
  final List<String> options;
  String? selectedOption;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
    this.selectedOption,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      question: json['question'] as String,
      category: json['category'] as String? ?? 'Flutter UI',
      options: List<String>.from(json['options'] as List),
    );
  }
}

class QuizResultCard {
  final int cardId;
  final String question;
  final String selectedOption;
  final String correctAnswer;
  final bool isCorrect;

  QuizResultCard({
    required this.cardId,
    required this.question,
    required this.selectedOption,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuizResultCard.fromJson(Map<String, dynamic> json) {
    return QuizResultCard(
      cardId: json['card_id'] as int,
      question: json['question'] as String,
      selectedOption: json['selected_option'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
    );
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final List<QuizResultCard> results;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.results,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      scorePercentage: (json['score_percentage'] as num).toDouble(),
      results: (json['results'] as List)
          .map((item) => QuizResultCard.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
