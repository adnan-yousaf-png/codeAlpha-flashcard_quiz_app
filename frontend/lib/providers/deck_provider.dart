import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../services/api_service.dart';

class DeckProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Deck> _decks = [];
  Deck? _selectedDeck;
  DeckStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DeckProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Deck> get decks => _decks;
  Deck? get selectedDeck => _selectedDeck;
  DeckStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDecks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _decks = await _apiService.fetchDecks();
      if (_decks.isNotEmpty) {
        // Default to first deck if none selected
        _selectedDeck ??= _decks.first;
        await loadStats(_selectedDeck!.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDeck(Deck deck) async {
    _selectedDeck = deck;
    notifyListeners();
    await loadStats(deck.id);
  }

  Future<void> loadStats(int deckId) async {
    try {
      _stats = await _apiService.fetchDeckStats(deckId);
      notifyListeners();
    } catch (e) {
      // Keep previous stats if error
    }
  }
}
