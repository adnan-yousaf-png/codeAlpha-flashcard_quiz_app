import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bar_header.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.scorePercentage.round();
    final isMastered = score >= 80;
    final isPassing = score >= 50;

    final badgeColor = isMastered
        ? AppColors.tertiaryFixed
        : (isPassing ? AppColors.secondaryFixed : AppColors.errorContainer);
    final badgeTextColor = isMastered
        ? AppColors.onTertiaryFixed
        : (isPassing ? AppColors.onSecondaryFixed : AppColors.onErrorContainer);
    final statusText = isMastered
        ? 'Mastery Achieved!'
        : (isPassing ? 'Good Effort!' : 'Keep Practicing!');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarHeader(
        title: 'Quiz Results',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Hero Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: AppColors.ambientCardShadow,
              ),
              child: Column(
                children: [
                  // Circular Score Wheel
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isMastered
                            ? [AppColors.tertiary, AppColors.tertiaryContainer]
                            : [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isMastered ? AppColors.tertiary : AppColors.primary).withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$score%',
                        style: AppTextStyles.headlineLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Performance Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.labelMd.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stat Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        label: 'Total',
                        value: '${result.totalQuestions}',
                        color: AppColors.onSurface,
                      ),
                      _buildMetric(
                        label: 'Correct',
                        value: '${result.correctAnswers}',
                        color: AppColors.tertiary,
                      ),
                      _buildMetric(
                        label: 'Incorrect',
                        value: '${result.totalQuestions - result.correctAnswers}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        'Retake Quiz',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.school_outlined, size: 20, color: AppColors.secondary),
                      label: Text(
                        'Back to Study',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
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

            // 3. Question-by-Question Breakdown
            Text(
              'Detailed Review',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            ...result.results.map((card) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: card.isCorrect ? AppColors.tertiaryFixed : AppColors.errorContainer,
                    width: 1,
                  ),
                  boxShadow: AppColors.ambientCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          card.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: card.isCorrect ? AppColors.tertiary : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.question,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: card.isCorrect
                            ? AppColors.tertiaryFixed.withAlpha(60)
                            : AppColors.errorContainer.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Your Answer: ${card.selectedOption}',
                        style: AppTextStyles.captionSm.copyWith(
                          color: card.isCorrect ? AppColors.onTertiaryFixed : AppColors.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!card.isCorrect) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed.withAlpha(60),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Correct Answer: ${card.correctAnswer}',
                          style: AppTextStyles.captionSm.copyWith(
                            color: AppColors.onTertiaryFixed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMd.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.captionSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
