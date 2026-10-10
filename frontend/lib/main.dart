import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deck_provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlashLearnApp());
}

class FlashLearnApp extends StatelessWidget {
  const FlashLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeckProvider()..loadDecks(),
        ),
        ChangeNotifierProvider(
          create: (_) => FlashcardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'FlashLearn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShell(),
      ),
    );
  }
}
