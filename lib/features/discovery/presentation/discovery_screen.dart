import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/models/cultural_model.dart';
import '../../../shared/repositories/cultural_repositories.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Watch filtered entries and categories
    final categoriesAsync = ref.watch(categoriesProvider);
    final entriesAsync = ref.watch(filteredCulturalEntriesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      backgroundColor: colors.cream,
      appBar: AppBar(
        title: Text(
          'Cultural Heritage',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CATEGORY FILTER PILLS
          SizedBox(
            height: 48,
            child: categoriesAsync.when(
              data: (categories) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // "All" filter chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: selectedCategory == null,
                        label: const Text('All Traditions'),
                        labelStyle: TextStyle(
                          color: selectedCategory == null
                              ? Colors.white
                              : colors.charcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        backgroundColor: colors.warmWhite,
                        selectedColor: colors.coral,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selectedCategory == null
                                ? colors.coral
                                : colors.mutedBrown.withValues(alpha: 0.2),
                          ),
                        ),
                        onSelected: (_) {
                          ref
                                  .read(selectedCategoryFilterProvider.notifier)
                                  .state =
                              null;
                        },
                      ),
                    ),
                    // Dynamic categories (Food, Textile, Dance, Architecture)
                    ...categories.map((cat) {
                      final isSelected = selectedCategory == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat.name),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colors.charcoal,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          backgroundColor: colors.warmWhite,
                          selectedColor: colors.coral,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? colors.coral
                                  : colors.mutedBrown.withValues(alpha: 0.2),
                            ),
                          ),
                          onSelected: (_) {
                            ref
                                .read(selectedCategoryFilterProvider.notifier)
                                .state = isSelected
                                ? null
                                : cat.id;
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),

          const SizedBox(height: 12),

          // 2. CULTURAL ENTRIES GRID / LIST
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No cultural items found in this category.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.mutedBrown,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _CulturalCatalogCard(
                      entry: entry,
                      onTap: () {
                        // Navigate to detail page
                        context.push('/cultural/${entry.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Error loading heritage: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editorial card for cultural catalog
class _CulturalCatalogCard extends StatelessWidget {
  final CulturalEntry entry;
  final VoidCallback onTap;

  const _CulturalCatalogCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.mutedBrown.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with UNESCO badge & Hero animation tag
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'cultural-image-${entry.id}',
                    child: Image.network(
                      entry.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) =>
                          Container(color: colors.charcoal),
                    ),
                  ),
                  if (entry.isUnescoRecognized)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.warmWhite.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: colors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'UNESCO HERITAGE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.localName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colors.mutedBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.charcoal.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Read Cultural Story',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.coral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: colors.coral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
