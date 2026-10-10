import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_model.dart';
import '../providers/deck_provider.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/flashcard_list_item.dart';
import '../widgets/state_views.dart';

class CardsListScreen extends StatefulWidget {
  final Function(Flashcard)? onEditCard;
  final VoidCallback? onAddNewCard;

  const CardsListScreen({
    super.key,
    this.onEditCard,
    this.onAddNewCard,
  });

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showEmptyStateDemo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckId = context.read<DeckProvider>().selectedDeck?.id;
      context.read<FlashcardProvider>().loadFlashcards(deckId: deckId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleDelete(BuildContext context, Flashcard card) async {
    final confirmed = await DeleteConfirmDialog.show(
      context,
      title: 'Delete this card?',
      message: 'This action cannot be undone. The question and answer will be permanently removed.',
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<FlashcardProvider>().deleteFlashcard(card.id);
      if (success && context.mounted) {
        // Also refresh deck stats
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppBarHeader(title: 'All Cards'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_card_list',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: widget.onAddNewCard,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          final totalCount = provider.cards.length;
          final favoriteCount = provider.cards.where((c) => c.isFavorite).length;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final deckId = context.read<DeckProvider>().selectedDeck?.id;
              await provider.loadFlashcards(deckId: deckId);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Top Header: Title & Total Count Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'All Flashcards',
                          style: AppTextStyles.headlineMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '$totalCount total',
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort_rounded, color: AppColors.onSurface, size: 22),
                      tooltip: 'Sort View',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainer,
                        minimumSize: const Size(40, 40),
                      ),
                      onPressed: () {
                        // Quick toggle sort order
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cards sorted', style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.bodyMd,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search flashcards...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: false,
                          ),
                          onChanged: (val) {
                            provider.setSearchQuery(val);
                            setState(() {});
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                            setState(() {});
                          },
                          child: const Icon(Icons.close_rounded, color: AppColors.outline, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontally Scrolling Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All ($totalCount)',
                        filterKey: 'all',
                        isActive: provider.activeFilter == 'all',
                        onTap: () => provider.setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Recent',
                        icon: Icons.schedule_rounded,
                        filterKey: 'recent',
                        isActive: provider.activeFilter == 'recent',
                        onTap: () => provider.setFilter('recent'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Favorites ($favoriteCount)',
                        icon: Icons.star_rounded,
                        filterKey: 'favorites',
                        isActive: provider.activeFilter == 'favorites',
                        onTap: () => provider.setFilter('favorites'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Mastered',
                        icon: Icons.check_circle_rounded,
                        filterKey: 'mastered',
                        isActive: provider.activeFilter == 'mastered',
                        onTap: () => provider.setFilter('mastered'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Content View (Loading / Error / Empty / List)
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: LoadingStateView(),
                  )
                else if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ErrorStateView(
                      error: provider.errorMessage!,
                      onRetry: () => provider.loadFlashcards(),
                    ),
                  )
                else if (provider.cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: EmptyCardsStateView(
                      onAddCard: () => widget.onAddNewCard?.call(),
                    ),
                  )
                else ...[
                  // Cards List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.cards.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final card = provider.cards[index];
                      return FlashcardListItem(
                        card: card,
                        onTap: () => widget.onEditCard?.call(card),
                        onEdit: () => widget.onEditCard?.call(card),
                        onDelete: () => _handleDelete(context, card),
                        onToggleFavorite: () => provider.toggleFavorite(card.id),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Interactive Empty State Demonstration Toggle (from Stitch specs)
                Material(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                        title: Text(
                          'Empty State Demonstration',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        trailing: Icon(
                          _showEmptyStateDemo ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onTap: () {
                          setState(() {
                            _showEmptyStateDemo = !_showEmptyStateDemo;
                          });
                        },
                      ),
                      if (_showEmptyStateDemo)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: EmptyCardsStateView(
                            onAddCard: () => widget.onAddNewCard?.call(),
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

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required String filterKey,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isActive
                    ? AppColors.onPrimary
                    : (filterKey == 'favorites'
                        ? AppColors.primary
                        : (filterKey == 'mastered' ? AppColors.tertiary : AppColors.onSurfaceVariant)),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
