import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_model.dart';
import '../providers/deck_provider.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/flip_flashcard_view.dart';
import '../widgets/state_views.dart';

class StudyScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAllCards;
  final Function(Flashcard)? onEditCard;
  final VoidCallback? onAddNewCard;
  final VoidCallback? onStartQuiz;

  const StudyScreen({
    super.key,
    this.onNavigateToAllCards,
    this.onEditCard,
    this.onAddNewCard,
    this.onStartQuiz,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deck = context.read<DeckProvider>().selectedDeck;
      context.read<FlashcardProvider>().loadFlashcards(deckId: deck?.id);
    });
  }

  void _handleDelete(BuildContext context, Flashcard card) async {
    final confirmed = await DeleteConfirmDialog.show(
      context,
      title: 'Delete this card?',
      message: 'This action cannot be undone. The question and answer will be permanently removed.',
    );

    if (confirmed == true && context.mounted) {
      await context.read<FlashcardProvider>().deleteFlashcard(card.id);
      if (context.mounted) {
        final deckId = context.read<DeckProvider>().selectedDeck?.id;
        if (deckId != null) {
          context.read<DeckProvider>().loadStats(deckId);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card deleted', style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
            backgroundColor: AppColors.onSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = context.watch<DeckProvider>();
    final deck = deckProvider.selectedDeck;
    final stats = deckProvider.stats;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarHeader(
        title: 'Study',
        trailing: widget.onStartQuiz != null
            ? Container(
                margin: const EdgeInsets.only(right: 4),
                child: TextButton.icon(
                  onPressed: widget.onStartQuiz,
                  icon: const Icon(Icons.quiz_outlined, size: 18, color: AppColors.primary),
                  label: Text(
                    'Quiz',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                ),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_card_study',
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: widget.onAddNewCard,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading && cardProvider.cards.isEmpty) {
            return const LoadingStateView(message: 'Loading study session...');
          }

          if (cardProvider.errorMessage != null && cardProvider.cards.isEmpty) {
            return ErrorStateView(
              error: cardProvider.errorMessage!,
              onRetry: () => cardProvider.loadFlashcards(deckId: deck?.id),
            );
          }

          if (cardProvider.cards.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: EmptyCardsStateView(
                  onAddCard: () => widget.onAddNewCard?.call(),
                ),
              ),
            );
          }

          final currentCard = cardProvider.currentCard;
          if (currentCard == null) return const SizedBox.shrink();

          final totalCards = cardProvider.cards.length;
          final currentIndex = cardProvider.currentIndex;
          final progressFraction = totalCards > 0 ? (currentIndex + 1) / totalCards : 0.0;
          final progressPercent = (progressFraction * 100).round();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await cardProvider.loadFlashcards(deckId: deck?.id);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Top Session Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Daily Deck',
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '$totalCards cards',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.onPrimaryFixed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${stats?.streakDays ?? 4} Day Streak',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Study Progress Header
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
                            'Card ${currentIndex + 1} of $totalCards',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$progressPercent% Completed',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.onSurfaceVariant,
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
                            value: progressFraction,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Tactile 3D Flashcard Stage
                FlipFlashcardView(
                  card: currentCard,
                  isFlipped: cardProvider.isFlipped,
                  onFlip: () => cardProvider.flipCard(),
                  onEdit: () => widget.onEditCard?.call(currentCard),
                  onDelete: () => _handleDelete(context, currentCard),
                ),
                const SizedBox(height: 16),

                // 4. Primary Action & Flip Control ("Show Answer" / "Hide Answer")
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => cardProvider.flipCard(),
                    icon: Icon(
                      cardProvider.isFlipped ? Icons.visibility_off_outlined : Icons.lightbulb_outline,
                      size: 20,
                    ),
                    label: Text(
                      cardProvider.isFlipped ? 'Hide Answer' : 'Show Answer',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cardProvider.isFlipped ? AppColors.onSurface : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardProvider.isFlipped
                          ? AppColors.surfaceContainerHigh
                          : AppColors.secondary,
                      foregroundColor: cardProvider.isFlipped ? AppColors.onSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: cardProvider.isFlipped ? 0 : 2,
                    ),
                  ),
                ),

                // 5. Spaced Repetition Grading Bar (Reveals when Flipped to Answer)
                if (cardProvider.isFlipped) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGradingButton(
                          label: 'Again',
                          interval: '<1m',
                          backgroundColor: AppColors.ratingAgainBg,
                          textColor: AppColors.onErrorContainer,
                          onTap: () => cardProvider.gradeCard(currentCard.id, 'Again'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGradingButton(
                          label: 'Hard',
                          interval: '6m',
                          backgroundColor: AppColors.ratingHardBg,
                          textColor: AppColors.onSurface,
                          onTap: () => cardProvider.gradeCard(currentCard.id, 'Hard'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGradingButton(
                          label: 'Good',
                          interval: '1d',
                          backgroundColor: AppColors.ratingGoodBg,
                          textColor: AppColors.primary,
                          onTap: () => cardProvider.gradeCard(currentCard.id, 'Good'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGradingButton(
                          label: 'Easy',
                          interval: '4d',
                          backgroundColor: AppColors.ratingEasyBg,
                          textColor: AppColors.onTertiaryFixed,
                          onTap: () => cardProvider.gradeCard(currentCard.id, 'Easy'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),

                // 6. Deck Navigation Controls (Prev, Dots, Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: currentIndex > 0 ? () => cardProvider.prevCard() : null,
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                          boxShadow: AppColors.ambientCardShadow,
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 26,
                          color: currentIndex > 0 ? AppColors.onSurface : AppColors.outlineVariant,
                        ),
                      ),
                    ),
                    // Dot Pagination Indicator
                    Row(
                      children: List.generate(
                        totalCards.clamp(1, 4),
                        (index) {
                          final isDotActive = (index == (currentIndex % 4));
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isDotActive ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDotActive ? AppColors.secondary : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          );
                        },
                      ),
                    ),
                    InkWell(
                      onTap: currentIndex < totalCards - 1 ? () => cardProvider.nextCard() : null,
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                          boxShadow: AppColors.ambientCardShadow,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 26,
                          color: currentIndex < totalCards - 1 ? AppColors.onSurface : AppColors.outlineVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 7. Answer State Callout Card / Secondary Perspective (from Stitch)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                    boxShadow: AppColors.ambientCardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.tertiary),
                                const SizedBox(width: 4),
                                Text(
                                  'ANSWER SNAPSHOT',
                                  style: AppTextStyles.captionSm.copyWith(
                                    color: AppColors.onTertiaryFixed,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Core Concept',
                            style: AppTextStyles.captionSm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentCard.answer,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Expand Deck Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need more topics?',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Add flashcards to expand this deck',
                              style: AppTextStyles.captionSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: widget.onAddNewCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLowest,
                          foregroundColor: AppColors.primary,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: Text(
                          'Create',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Clearance for bottom navigation bar and FAB
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradingButton({
    required String label,
    required String interval,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.captionSm.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              interval,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withAlpha(180),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
