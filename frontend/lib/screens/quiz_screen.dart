import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/state_views.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int? deckId;

  const QuizScreen({super.key, this.deckId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetDeckId = widget.deckId ?? context.read<DeckProvider>().selectedDeck?.id ?? 1;
      context.read<QuizProvider>().startQuiz(deckId: targetDeckId, count: 6);
    });
  }

  void _handleSubmit() async {
    final quizProvider = context.read<QuizProvider>();
    final targetDeckId = widget.deckId ?? context.read<DeckProvider>().selectedDeck?.id ?? 1;

    final success = await quizProvider.submitQuiz(targetDeckId);
    if (!mounted) return;

    if (success && quizProvider.quizResult != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(result: quizProvider.quizResult!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quizProvider.errorMessage ?? 'Failed to submit quiz',
            style: AppTextStyles.labelMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarHeader(
        title: 'Quiz Challenge',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingStateView(message: 'Generating multiple-choice quiz...');
          }

          if (provider.errorMessage != null && provider.questions.isEmpty) {
            return ErrorStateView(
              error: provider.errorMessage!,
              onRetry: () {
                final targetDeckId = widget.deckId ?? context.read<DeckProvider>().selectedDeck?.id ?? 1;
                provider.startQuiz(deckId: targetDeckId);
              },
            );
          }

          if (provider.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz_outlined, size: 48, color: AppColors.outline),
                    const SizedBox(height: 12),
                    Text(
                      'Not enough cards for quiz',
                      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least 2 cards to this deck to take a multiple-choice quiz.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final currentQ = provider.currentQuestion;
          if (currentQ == null) return const SizedBox.shrink();

          final total = provider.questions.length;
          final currentIdx = provider.currentQuestionIndex;
          final progress = (currentIdx + 1) / total;
          final isLast = provider.isLastQuestion;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Progress Header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                    boxShadow: AppColors.ambientCardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${currentIdx + 1} of $total',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              currentQ.category,
                              style: AppTextStyles.captionSm.copyWith(
                                color: AppColors.onPrimaryFixed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Question Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                    boxShadow: AppColors.ambientCardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'MULTIPLE CHOICE',
                          style: AppTextStyles.captionSm.copyWith(
                            color: AppColors.onSecondaryFixed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentQ.question,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Four Option Tiles
                ...List.generate(currentQ.options.length, (optIdx) {
                  final optionText = currentQ.options[optIdx];
                  final isSelected = currentQ.selectedOption == optionText;
                  final optionLetters = ['A', 'B', 'C', 'D'];
                  final letter = optIdx < 4 ? optionLetters[optIdx] : '${optIdx + 1}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => provider.selectOption(optionText),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryFixed.withAlpha(90)
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? AppColors.floatingCardShadow : AppColors.ambientCardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Letter Circle Badge
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: isSelected ? Colors.white : AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Option Answer Text
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  optionText,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // 4. Navigation & Submit Actions
                Row(
                  children: [
                    if (currentIdx > 0) ...[
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => provider.prevQuestion(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: Text(
                              'Previous',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: currentQ.selectedOption == null
                              ? null
                              : () {
                                  if (isLast) {
                                    _handleSubmit();
                                  } else {
                                    provider.nextQuestion();
                                  }
                                },
                          icon: provider.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 20),
                          label: Text(
                            provider.isSubmitting
                                ? 'Submitting...'
                                : (isLast ? 'Submit Quiz' : 'Next Question'),
                            style: AppTextStyles.labelMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
