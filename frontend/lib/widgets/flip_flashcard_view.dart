import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FlipFlashcardView extends StatefulWidget {
  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FlipFlashcardView({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<FlipFlashcardView> createState() => _FlipFlashcardViewState();
}

class _FlipFlashcardViewState extends State<FlipFlashcardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180), // Stitch spec: Curves.easeInOut • 180ms
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant FlipFlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Stitch Spec: Matrix4 perspective 0.001 and Y-axis rotation
        final angle = _animation.value * pi;
        final isBack = _animation.value >= 0.5;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective Transform
          ..rotateY(angle); // Flip Axis: Y-Axis

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(pi), // Invert back face so text isn't mirrored
                  alignment: Alignment.center,
                  child: _buildCardContent(isAnswer: true),
                )
              : _buildCardContent(isAnswer: false),
        );
      },
    );
  }

  Widget _buildCardContent({required bool isAnswer}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 310),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.ambientCardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Top Meta Bar: Badge & Action Controls (Edit / Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge (Question / Answer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAnswer ? AppColors.tertiaryFixed : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isAnswer ? AppColors.tertiary : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAnswer ? 'ANSWER' : 'QUESTION',
                      style: AppTextStyles.captionSm.copyWith(
                        color: isAnswer ? AppColors.onTertiaryFixed : AppColors.onPrimaryFixed,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Action controls (Edit / Delete)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: widget.onEdit,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Central Card Core Content (Tappable to Flip)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onFlip,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: isAnswer
                      ? SingleChildScrollView(
                          child: Text(
                            widget.card.answer,
                            style: AppTextStyles.bodyLg.copyWith(
                              height: 1.5,
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.card.question,
                              style: AppTextStyles.headlineMd.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                                color: AppColors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.touch_app_outlined, size: 15, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tap to flip card',
                                    style: AppTextStyles.captionSm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Flip Hint Anchor: Topic Tag & Quick Flip Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    widget.card.category,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onFlip,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sync_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
