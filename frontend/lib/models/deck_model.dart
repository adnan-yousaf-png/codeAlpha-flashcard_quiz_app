class Deck {
  final int id;
  final String name;
  final String? description;
  final String category;
  final DateTime createdAt;
  final int cardCount;
  final int masteredCount;

  Deck({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.createdAt,
    this.cardCount = 0,
    this.masteredCount = 0,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Mobile Core Dev',
      createdAt: DateTime.parse(json['created_at'] as String),
      cardCount: json['card_count'] as int? ?? 0,
      masteredCount: json['mastered_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'card_count': cardCount,
      'mastered_count': masteredCount,
    };
  }
}

class DeckStats {
  final int totalCards;
  final int masteredCards;
  final int needsReviewCards;
  final int streakDays;

  DeckStats({
    required this.totalCards,
    required this.masteredCards,
    required this.needsReviewCards,
    this.streakDays = 4,
  });

  factory DeckStats.fromJson(Map<String, dynamic> json) {
    return DeckStats(
      totalCards: json['total_cards'] as int? ?? 0,
      masteredCards: json['mastered_cards'] as int? ?? 0,
      needsReviewCards: json['needs_review_cards'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 4,
    );
  }
}
