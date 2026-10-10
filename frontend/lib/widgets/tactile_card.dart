import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TactileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const TactileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.border,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: shadows ?? AppColors.ambientCardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
