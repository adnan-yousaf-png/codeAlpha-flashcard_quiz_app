import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../services/api_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _activeFilter = 'all'; // all, recent, favorites, mastered
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  FlashcardProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Flashcard> get cards => _cards;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Flashcard? get currentCard {
    if (_cards.isEmpty || _currentIndex >= _cards.length) return null;
    return _cards[_currentIndex];
  }

  // --- Study Navigation ---
  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void setFlipped(bool flipped) {
    _isFlipped = flipped;
    notifyListeners();
  }

  void nextCard() {
    if (_currentIndex < _cards.length - 1) {
      _currentIndex++;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void prevCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void goToCard(int index) {
    if (index >= 0 && index < _cards.length) {
      _currentIndex = index;
      _isFlipped = false;
      notifyListeners();
    }
  }

  // --- Filtering & Search ---
  void setFilter(String filter) {
    if (_activeFilter != filter) {
      _activeFilter = filter;
      notifyListeners();
      loadFlashcards();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadFlashcards();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
    loadFlashcards();
  }

  // --- API Operations ---
  Future<void> loadFlashcards({int? deckId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _apiService.fetchFlashcards(
        deckId: deckId,
        category: _selectedCategory,
        filterType: _activeFilter,
        search: _searchQuery,
      );
      if (_currentIndex >= _cards.length) {
        _currentIndex = 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createFlashcard({
    required int deckId,
    required String question,
    required String answer,
    String? category,
  }) async {
    try {
      final newCard = await _apiService.createFlashcard(
        deckId: deckId,
        question: question,
        answer: answer,
        category: category,
      );
      _cards.insert(0, newCard);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFlashcard({
    required int id,
    String? question,
    String? answer,
    String? category,
    bool? isFavorite,
    int? masteryPercentage,
  }) async {
    try {
      final updated = await _apiService.updateFlashcard(
        id: id,
        question: question,
        answer: answer,
        category: category,
        isFavorite: isFavorite,
        masteryPercentage: masteryPercentage,
      );
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFlashcard(int id) async {
    try {
      final success = await _apiService.deleteFlashcard(id);
      if (success) {
        _cards.removeWhere((c) => c.id == id);
        if (_currentIndex >= _cards.length) {
          _currentIndex = _cards.isNotEmpty ? _cards.length - 1 : 0;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final updated = await _apiService.toggleFavorite(id);
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> gradeCard(int id, String grade) async {
    try {
      final updated = await _apiService.gradeFlashcard(id, grade);
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = updated;
      }
      // Move to next card after grading
      nextCard();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
