import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'category_chip.dart';

class FlashcardListItem extends StatelessWidget {
  final Flashcard card;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const FlashcardListItem({
    super.key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  });

  String _formatStatus() {
    if (card.masteryPercentage >= 80) {
      return 'Mastered ${card.masteryPercentage}%';
    } else if (card.lastStudiedAt != null) {
      final diff = DateTime.now().difference(card.lastStudiedAt!);
      if (diff.inHours < 1) {
        return 'Studied recently';
      } else if (diff.inHours < 24) {
        return 'Studied ${diff.inHours}h ago';
      } else {
        return 'Studied ${diff.inDays}d ago';
      }
    }
    return 'Needs review';
  }

  IconData _formatStatusIcon() {
    if (card.masteryPercentage >= 80) {
      return Icons.psychology_rounded;
    } else if (card.lastStudiedAt != null) {
      return Icons.history_rounded;
    }
    return Icons.bolt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.ambientCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta: Category Tag & Favorite Star
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryChip(label: card.category),
                    IconButton(
                      icon: Icon(
                        card.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: card.isFavorite ? AppColors.primary : AppColors.outlineVariant,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Question Title
                Text(
                  card.question,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Answer Preview
                Text(
                  card.answer,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Bottom Strip Footer: Mastery Status & Action Icons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withAlpha(160),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _formatStatusIcon(),
                            size: 15,
                            color: card.masteryPercentage >= 80 ? AppColors.primary : AppColors.outline,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatStatus(),
                            style: AppTextStyles.captionSm.copyWith(
                              color: card.masteryPercentage >= 80 ? AppColors.primary : AppColors.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.onSurfaceVariant,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: AppColors.onSurfaceVariant,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
