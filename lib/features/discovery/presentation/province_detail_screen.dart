import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/repositories/cultural_repositories.dart';

class ProvinceDetailScreen extends ConsumerWidget {
  final String provinceId;

  const ProvinceDetailScreen({super.key, required this.provinceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Watch live Supabase providers
    final provincesAsync = ref.watch(provincesProvider);
    final destinationsAsync = ref.watch(allDestinationsProvider);
    final culturalAsync = ref.watch(culturalEntriesProvider);

    return provincesAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.cream,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.cream,
        body: Center(child: Text('Error: $err')),
      ),
      data: (provinces) {
        final province = provinces.firstWhere(
          (p) => p.id.trim() == provinceId.trim(),
          orElse: () => provinces.isNotEmpty
              ? provinces.first
              : MockCulturalData.provinces.first,
        );

        final allDestinations = destinationsAsync.value ?? [];
        final provinceDestinations = allDestinations
            .where((d) => d.provinceId.trim() == province.id.trim())
            .toList();

        final allCultural = culturalAsync.value ?? [];
        final provinceCultural = allCultural
            .where((c) =>
                c.provinceIds.map((id) => id.trim()).contains(province.id.trim()))
            .toList();

        return Scaffold(
          backgroundColor: colors.cream,
          body: CustomScrollView(
            slivers: [
              // 1. COLLAPSING HERO APPBAR
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: colors.cream,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: colors.warmWhite.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: colors.charcoal,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: province.heroImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (ctx, _) => Container(color: colors.cream),
                        errorWidget: (ctx, _, _) =>
                            Container(color: colors.charcoal),
                      ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      // Province Title Overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              province.name,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              province.localName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. CONTENT SECTIONS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Capital and Map Shortcut Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                size: 18,
                                color: colors.coral,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Capital: ${province.capital}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.charcoal,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/map'),
                            icon: Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: colors.coral,
                            ),
                            label: Text(
                              'View on Map',
                              style: TextStyle(
                                color: colors.coral,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tagline Callout Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.warmWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colors.mutedBrown.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          province.tagline,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colors.charcoal,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 3. DESTINATIONS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Destinations in ${province.name}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${provinceDestinations.length} places',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.mutedBrown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (provinceDestinations.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.warmWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.mutedBrown.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No destinations cataloged for this region yet.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.mutedBrown,
                              ),
                            ),
                          ),
                        )
                      else
                        ...provinceDestinations.map((dest) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () =>
                                  context.push('/destination/${dest.id}'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.warmWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colors.mutedBrown
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: dest.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, _) =>
                                            Container(color: colors.cream),
                                        errorWidget: (ctx, _, _) =>
                                            Container(color: colors.charcoal),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dest.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dest.cityOrRegency,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: colors.coral,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${dest.rating} ★ • ${dest.entryFeeRange}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: colors.mutedBrown,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: colors.mutedBrown,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 28),

                      // 4. CULTURAL HERITAGE & FOODS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cultural Traditions & Food',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${provinceCultural.length} traditions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.mutedBrown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (provinceCultural.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.warmWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.mutedBrown.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No cultural entries cataloged for this region yet.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.mutedBrown,
                              ),
                            ),
                          ),
                        )
                      else
                        ...provinceCultural.map((cultural) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () =>
                                  context.push('/cultural/${cultural.id}'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.warmWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colors.mutedBrown
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: cultural.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, _) =>
                                            Container(color: colors.cream),
                                        errorWidget: (ctx, _, _) =>
                                            Container(color: colors.charcoal),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cultural.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cultural.summary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: colors.charcoal
                                                  .withValues(alpha: 0.75),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: colors.mutedBrown,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

