import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = backgroundColor ?? AppColors.primaryFixed;
    Color fg = textColor ?? AppColors.onPrimaryFixed;

    // Adaptive styling based on category if not explicitly provided
    if (backgroundColor == null) {
      final l = label.toLowerCase();
      if (l.contains('flutter') || l.contains('ui')) {
        bg = AppColors.primaryFixed;
        fg = AppColors.onPrimaryFixed;
      } else if (l.contains('state')) {
        bg = AppColors.secondaryFixed;
        fg = AppColors.onSecondaryFixed;
      } else if (l.contains('arch')) {
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
      } else {
        bg = AppColors.surfaceContainer;
        fg = AppColors.onSurfaceVariant;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.captionSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
