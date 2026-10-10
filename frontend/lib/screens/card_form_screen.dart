import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_model.dart';
import '../providers/deck_provider.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bar_header.dart';

class CardFormScreen extends StatefulWidget {
  final Flashcard? initialCard;

  const CardFormScreen({
    super.key,
    this.initialCard,
  });

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;

  bool _isEditMode = false;
  bool _showQuestionError = false;
  bool _isSaving = false;
  String _selectedCategory = 'Flutter UI';

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.initialCard != null;
    _questionController = TextEditingController(text: widget.initialCard?.question ?? '');
    _answerController = TextEditingController(text: widget.initialCard?.answer ?? '');
    if (widget.initialCard != null) {
      _selectedCategory = widget.initialCard!.category;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _switchMode(bool edit) {
    if (_isEditMode == edit) return;
    setState(() {
      _isEditMode = edit;
      if (!edit) {
        // Switched to New: clear fields
        _questionController.clear();
        _answerController.clear();
        _showQuestionError = false;
      } else if (widget.initialCard != null) {
        // Switched back to Edit: restore initial
        _questionController.text = widget.initialCard!.question;
        _answerController.text = widget.initialCard!.answer;
        _showQuestionError = false;
      }
    });
  }

  Future<void> _handleSave() async {
    final questionText = _questionController.text.trim();
    final answerText = _answerController.text.trim();

    if (questionText.isEmpty) {
      setState(() {
        _showQuestionError = true;
      });
      return;
    }

    setState(() {
      _showQuestionError = false;
      _isSaving = true;
    });

    final deckProvider = context.read<DeckProvider>();
    final cardProvider = context.read<FlashcardProvider>();
    final deckId = deckProvider.selectedDeck?.id ?? 1;

    bool success = false;
    if (_isEditMode && widget.initialCard != null) {
      success = await cardProvider.updateFlashcard(
        id: widget.initialCard!.id,
        question: questionText,
        answer: answerText.isNotEmpty ? answerText : 'No answer provided',
        category: _selectedCategory,
      );
    } else {
      success = await cardProvider.createFlashcard(
        deckId: deckId,
        question: questionText,
        answer: answerText.isNotEmpty ? answerText : 'No answer provided',
        category: _selectedCategory,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      // Refresh deck stats
      deckProvider.loadStats(deckId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _isEditMode ? 'Card updated successfully!' : 'Card saved to deck!',
                style: AppTextStyles.labelMd.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cardProvider.errorMessage ?? 'Failed to save card',
            style: AppTextStyles.labelMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>().selectedDeck;
    final deckName = deck?.name ?? 'Mobile Core Dev';
    final cardNum = widget.initialCard != null
        ? '#${widget.initialCard!.id}'
        : '#${(deck?.cardCount ?? 12) + 1}';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarHeader(
        title: 'Deck Details',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Deck Archetype Header & Mode Switcher
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: AppColors.ambientCardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.style_rounded, color: AppColors.onPrimaryFixed, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deck: $deckName',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Card $cardNum in Spaced Repetition',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Segmented Mode Switcher (+ New / Edit)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        _buildModeTab(
                          label: 'New',
                          icon: Icons.add,
                          isSelected: !_isEditMode,
                          onTap: () => _switchMode(false),
                        ),
                        _buildModeTab(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          isSelected: _isEditMode,
                          onTap: () => _switchMode(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. State Banner Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditMode ? 'Editing Card $cardNum' : 'Creating Card',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded, color: AppColors.tertiary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Autosaved draft',
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Main Form Surface
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: AppColors.ambientCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Field Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Question Prompt',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '${_questionController.text.length} / 200',
                        style: AppTextStyles.captionSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Question Text Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextField(
                      controller: _questionController,
                      maxLength: 200,
                      maxLines: 3,
                      style: AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        hintText: 'e.g., What is a Flutter Widget hierarchy node?',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val.trim().isNotEmpty) {
                            _showQuestionError = false;
                          }
                        });
                      },
                    ),
                  ),

                  // Inline Validation Warning
                  if (_showQuestionError) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Question cannot be empty',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Target Answer Field Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Target Answer',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '${_answerController.text.length} / 300',
                        style: AppTextStyles.captionSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Target Answer Text Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextField(
                      controller: _answerController,
                      maxLength: 300,
                      maxLines: 4,
                      style: AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        hintText: 'e.g., A widget is an immutable description of a part of a user interface.',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Formatting Toolbar (Pill Actions from Stitch)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFormatPill(label: 'Bold', icon: Icons.format_bold_rounded),
                        const SizedBox(width: 8),
                        _buildFormatPill(label: 'Code', icon: Icons.code_rounded),
                        const SizedBox(width: 8),
                        _buildFormatPill(label: 'Media', icon: Icons.image_outlined),
                        const SizedBox(width: 8),
                        _buildFormatPill(label: 'Cloze', icon: Icons.visibility_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Study Best-Practice Tip Callout (Active Recall Tip)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.onSecondaryFixed, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Recall Tip',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep questions concise for optimal recall during study sessions. Break complex multi-clause ideas into atomic flashcards.',
                          style: AppTextStyles.bodyMd.copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 5. Difficulty Algorithm Micro-Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: AppColors.ambientCardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Difficulty algorithm:',
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Dynamic SM-2',
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.onSecondaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. Action Controls: Save & Cancel
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : (_isEditMode ? 'Update Changes' : 'Save Card'),
                  style: AppTextStyles.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant),
                label: Text(
                  'Cancel',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.captionSm.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatPill({required String label, required IconData icon}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurface),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
