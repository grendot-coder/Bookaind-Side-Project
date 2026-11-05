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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NUSANTARA HERITAGE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.coral,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Just Move It, Explorer',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: colors.coralSubtle,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: colors.charcoal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search Bar Mock
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.warmWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.mutedBrown.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: colors.mutedBrown),
                          const SizedBox(width: 12),
                          Text(
                            'Search temples, batik, royal cuisines...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.mutedBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Featured Destinations Carousel
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Wonders of Java',
                    subtitle:
                        'Iconic heritage destinations to begin your journey',
                  ),
                  SizedBox(
                    height: 285,
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

            // 3. Explore Provinces of Java
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Explore Provinces',
                    subtitle: 'Six diverse cultural regions across Java',
                  ),
                  SizedBox(
                    height: 130,
                    child: provincesAsync.when(
                      data: (provinces) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: provinces.length,
                        itemBuilder: (context, index) {
                          return ProvinceCard(
                            province: provinces[index],
                            onTap: () {},
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

            // 4. Traditional Food Previews
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Discover Traditional Food',
                    subtitle:
                        'Time-honored recipes passed down through generations',
                  ),
                  culinaryAsync.when(
                    data: (entries) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: colors.warmWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.mutedBrown.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                            ),
                            // clipBehavior keeps the ripple effect inside the rounded corners!
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              // 👉 Tapping now navigates to the Cultural Detail page!
                              onTap: () =>
                                  context.push('/cultural/${entry.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        entry.imageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) => Container(
                                          width: 70,
                                          height: 70,
                                          color: colors.saffronSubtle,
                                          child: Icon(
                                            Icons.restaurant,
                                            color: colors.saffron,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            entry.summary,
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                  MapTeaserCard(onTap: () => context.push('/map')),
                  AiAssistantTeaserCard(
                    onTap: () => context.push('/ai-assistant'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
