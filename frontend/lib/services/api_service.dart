import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/deck_model.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // --- Decks ---
  Future<List<Deck>> fetchDecks() async {
    final response = await _client.get(Uri.parse(ApiConfig.decks));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Deck.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load decks: ${response.statusCode}');
    }
  }

  Future<Deck> fetchDeck(int deckId) async {
    final response = await _client.get(Uri.parse(ApiConfig.deck(deckId)));
    if (response.statusCode == 200) {
      return Deck.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load deck $deckId: ${response.statusCode}');
    }
  }

  Future<DeckStats> fetchDeckStats(int deckId) async {
    final response = await _client.get(Uri.parse(ApiConfig.deckStats(deckId)));
    if (response.statusCode == 200) {
      return DeckStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load deck stats: ${response.statusCode}');
    }
  }

  // --- Flashcards ---
  Future<List<Flashcard>> fetchFlashcards({
    int? deckId,
    String? category,
    String? filterType,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (deckId != null) queryParams['deck_id'] = deckId.toString();
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (filterType != null && filterType.isNotEmpty) queryParams['filter_type'] = filterType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(ApiConfig.flashcards).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Flashcard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flashcards: ${response.statusCode}');
    }
  }

  Future<Flashcard> fetchFlashcard(int id) async {
    final response = await _client.get(Uri.parse(ApiConfig.flashcard(id)));
    if (response.statusCode == 200) {
      return Flashcard.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load flashcard $id: ${response.statusCode}');
    }
  }

  Future<Flashcard> createFlashcard({
    required int deckId,
    required String question,
    required String answer,
    String? category,
  }) async {
    final body = json.encode({
      'deck_id': deckId,
      'question': question,
      'answer': answer,
      'category': category ?? 'Flutter UI',
    });

    final response = await _client.post(
      Uri.parse(ApiConfig.flashcards),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return Flashcard.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create flashcard');
    }
  }

  Future<Flashcard> updateFlashcard({
    required int id,
    String? question,
    String? answer,
    String? category,
    bool? isFavorite,
    int? masteryPercentage,
  }) async {
    final bodyData = <String, dynamic>{};
    if (question != null) bodyData['question'] = question;
    if (answer != null) bodyData['answer'] = answer;
    if (category != null) bodyData['category'] = category;
    if (isFavorite != null) bodyData['is_favorite'] = isFavorite;
    if (masteryPercentage != null) bodyData['mastery_percentage'] = masteryPercentage;

    final response = await _client.put(
      Uri.parse(ApiConfig.flashcard(id)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bodyData),
    );

    if (response.statusCode == 200) {
      return Flashcard.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update flashcard');
    }
  }

  Future<bool> deleteFlashcard(int id) async {
    final response = await _client.delete(Uri.parse(ApiConfig.flashcard(id)));
    return response.statusCode == 204;
  }

  Future<Flashcard> toggleFavorite(int id) async {
    final response = await _client.patch(Uri.parse(ApiConfig.flashcardFavorite(id)));
    if (response.statusCode == 200) {
      return Flashcard.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  }

  Future<Flashcard> gradeFlashcard(int id, String grade) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.flashcardGrade(id)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'grade': grade}),
    );

    if (response.statusCode == 200) {
      return Flashcard.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to grade flashcard: ${response.statusCode}');
    }
  }

  // --- Quiz ---
  Future<List<QuizQuestion>> generateQuiz({int? deckId, int count = 10}) async {
    final queryParams = {'count': count.toString()};
    if (deckId != null) queryParams['deck_id'] = deckId.toString();

    final uri = Uri.parse(ApiConfig.quiz).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => QuizQuestion.fromJson(json)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to generate quiz');
    }
  }

  Future<QuizResult> submitQuiz({
    required int deckId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.quizSubmit),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'deck_id': deckId,
        'answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      return QuizResult.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to submit quiz');
    }
  }
}
