import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Base URL configured for local dev:
  /// - Android emulator uses 10.0.2.2 to reach host machine localhost.
  /// - Windows / Web / iOS simulator use 127.0.0.1.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {
      // In case Platform check is unsupported
    }
    return 'http://127.0.0.1:8000';
  }

  // Decks endpoints
  static String get decks => '$baseUrl/api/decks';
  static String deck(int id) => '$baseUrl/api/decks/$id';
  static String deckStats(int id) => '$baseUrl/api/decks/$id/stats';

  // Flashcards endpoints
  static String get flashcards => '$baseUrl/api/flashcards';
  static String flashcard(int id) => '$baseUrl/api/flashcards/$id';
  static String flashcardFavorite(int id) => '$baseUrl/api/flashcards/$id/favorite';
  static String flashcardGrade(int id) => '$baseUrl/api/flashcards/$id/grade';

  // Quiz endpoints
  static String get quiz => '$baseUrl/api/quiz';
  static String get quizSubmit => '$baseUrl/api/quiz/submit';
}
