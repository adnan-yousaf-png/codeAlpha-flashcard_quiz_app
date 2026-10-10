import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    this.title = 'Delete this card?',
    this.message = 'This action cannot be undone. The question and answer will be permanently removed.',
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Delete this card?',
    String message = 'This action cannot be undone. The question and answer will be permanently removed.',
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (ctx) => DeleteConfirmDialog(
        title: title,
        message: message,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered Red Trash Icon Badge
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        foregroundColor: AppColors.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      onPressed: onConfirm,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        'Delete',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
