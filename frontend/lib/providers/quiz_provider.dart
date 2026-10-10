import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  QuizResult? _quizResult;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  QuizProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizResult? get quizResult => _quizResult;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  bool get allAnswered => _questions.isNotEmpty && _questions.every((q) => q.selectedOption != null);

  Future<void> startQuiz({int? deckId, int count = 5}) async {
    _isLoading = true;
    _errorMessage = null;
    _quizResult = null;
    _currentQuestionIndex = 0;
    notifyListeners();

    try {
      _questions = await _apiService.generateQuiz(deckId: deckId, count: count);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOption(String option) {
    if (currentQuestion != null) {
      currentQuestion!.selectedOption = option;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<bool> submitQuiz(int deckId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final answers = _questions.map((q) => {
        'card_id': q.id,
        'selected_option': q.selectedOption ?? '',
      }).toList();

      _quizResult = await _apiService.submitQuiz(deckId: deckId, answers: answers);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _quizResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
