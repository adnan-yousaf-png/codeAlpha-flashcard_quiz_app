class Flashcard {
  final int id;
  final int deckId;
  final String question;
  final String answer;
  final String category;
  final bool isFavorite;
  final int masteryPercentage;
  final String difficultyInterval;
  final DateTime? lastStudiedAt;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.category = 'Flutter UI',
    this.isFavorite = false,
    this.masteryPercentage = 0,
    this.difficultyInterval = '1d',
    this.lastStudiedAt,
    required this.createdAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as int,
      deckId: json['deck_id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String? ?? 'Flutter UI',
      isFavorite: json['is_favorite'] as bool? ?? false,
      masteryPercentage: json['mastery_percentage'] as int? ?? 0,
      difficultyInterval: json['difficulty_interval'] as String? ?? '1d',
      lastStudiedAt: json['last_studied_at'] != null
          ? DateTime.tryParse(json['last_studied_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'question': question,
      'answer': answer,
      'category': category,
      'is_favorite': isFavorite,
      'mastery_percentage': masteryPercentage,
      'difficulty_interval': difficultyInterval,
      'last_studied_at': lastStudiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Flashcard copyWith({
    int? id,
    int? deckId,
    String? question,
    String? answer,
    String? category,
    bool? isFavorite,
    int? masteryPercentage,
    String? difficultyInterval,
    DateTime? lastStudiedAt,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
      difficultyInterval: difficultyInterval ?? this.difficultyInterval,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
