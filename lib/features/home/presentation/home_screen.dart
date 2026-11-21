import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/repositories/cultural_repositories.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/featured_destination_card.dart';
import '../../../shared/widgets/province_card.dart';
import '../../../shared/widgets/teaser_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Watch providers from our repository
    final destinationsAsync = ref.watch(featuredDestinationsProvider);
    final provincesAsync = ref.watch(provincesProvider);
    final culinaryAsync = ref.watch(culinaryEntriesProvider);

    return Scaffold(
      backgroundColor: colors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Editorial Header & Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: greeting + weather badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOOKAIND',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.coral,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Discover Nusantara',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Weather cosmetic badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warmWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('☀️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Weather',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.mutedBrown,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '32° C',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.charcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search Bar — interactive floating pill with shadow
                    GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: colors.warmWhite,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: colors.coral),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search temples, batik, royal cuisines...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.mutedBrown,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.cream,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: colors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Category filter pills — horizontal scroll
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _HomeFilterChip.items.map((item) {
                          return _HomeFilterChip(
                            item: item,
                            onTap: () => context.push('/discover'),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),

            // 2. Featured Destinations Carousel
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SectionHeader(
                    title: 'Wonders of Nusantara',
                    subtitle: 'Iconic heritage destinations to begin your journey',
                    isLarge: true,
                  ),
                  SizedBox(
                    height: 290,
                    child: destinationsAsync.when(
                      data: (destinations) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          return FeaturedDestinationCard(
                            destination: destinations[index],
                            onTap: () => context.push(
                              '/destination/${destinations[index].id}',
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Explore Provinces
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Explore Provinces',
                    subtitle: 'More than 30 culturally diversed provinces',
                  ),
                  SizedBox(
                    height: 150,
                    child: provincesAsync.when(
                      data: (provinces) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: provinces.length,
                        itemBuilder: (context, index) {
                          return ProvinceCard(
                            province: provinces[index],
                            onTap: () => context.push(
                              '/province/${provinces[index].id}',
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Traditional Food — wider horizontal photo cards
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Traditional Food',
                    subtitle: 'Time-honored recipes passed down through generations',
                  ),
                  culinaryAsync.when(
                    data: (entries) => SizedBox(
                      height: 190,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return GestureDetector(
                            onTap: () => context.push('/cultural/${entry.id}'),
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: colors.warmWhite,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Food image — wider, magazine-style
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Image.network(
                                      entry.imageUrl,
                                      width: 150,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, _, _) => Container(
                                        width: 150,
                                        height: 110,
                                        color: colors.saffronSubtle,
                                        child: Icon(
                                          Icons.restaurant,
                                          color: colors.saffron,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10, 8, 10, 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.title,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          entry.summary,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colors.mutedBrown,
                                                fontSize: 11,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),

            // 5. Interactive Teasers (Map & AI Guide)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  MapTeaserCard(onTap: () => context.push('/map')),
                  AiAssistantTeaserCard(
                    onTap: () => context.push('/ai-assistant'),
                  ),
                  // Extra bottom padding for the floating nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home category filter chip
// ---------------------------------------------------------------------------

class _HomeFilterItem {
  final IconData icon;
  final String label;
  const _HomeFilterItem({required this.icon, required this.label});
}

class _HomeFilterChip extends StatelessWidget {
  final _HomeFilterItem item;
  final VoidCallback onTap;

  const _HomeFilterChip({required this.item, required this.onTap});

  static const items = [
    _HomeFilterItem(icon: Icons.temple_buddhist_rounded, label: 'Heritage'),
    _HomeFilterItem(icon: Icons.forest_rounded, label: 'Nature'),
    _HomeFilterItem(icon: Icons.waves_rounded, label: 'Marine'),
    _HomeFilterItem(icon: Icons.restaurant_rounded, label: 'Food'),
    _HomeFilterItem(icon: Icons.palette_rounded, label: 'Arts'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: colors.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.mutedBrown.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 15, color: colors.coral),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
