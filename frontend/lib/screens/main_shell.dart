import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../widgets/app_bottom_nav.dart';
import 'card_form_screen.dart';
import 'cards_list_screen.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  void _navigateToAddNewCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CardFormScreen(),
      ),
    );
  }

  void _navigateToEditCard(Flashcard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardFormScreen(initialCard: card),
      ),
    );
  }

  void _navigateToQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QuizScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // Tab 0: Study Screen
          StudyScreen(
            onNavigateToAllCards: () => setState(() => _currentTabIndex = 1),
            onAddNewCard: _navigateToAddNewCard,
            onEditCard: _navigateToEditCard,
            onStartQuiz: _navigateToQuiz,
          ),
          // Tab 1: All Cards Screen
          CardsListScreen(
            onAddNewCard: _navigateToAddNewCard,
            onEditCard: _navigateToEditCard,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}
