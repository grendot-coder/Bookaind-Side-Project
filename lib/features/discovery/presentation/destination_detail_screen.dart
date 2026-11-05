import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';

class DestinationDetailScreen extends StatelessWidget {
  final String destinationId;

  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Look up the destination from our mock dataset
    final destination = MockCulturalData.featuredDestinations.firstWhere(
      (d) => d.id == destinationId,
      orElse: () => MockCulturalData.featuredDestinations.first,
    );

    // Find the associated province name
    final province = MockCulturalData.provinces.firstWhere(
      (p) => p.id == destination.provinceId,
      orElse: () => MockCulturalData.provinces.first,
    );

    return Scaffold(
      backgroundColor: colors.cream,
      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING HERO IMAGE APPBAR WITH HERO ANIMATION
          SliverAppBar(
            expandedHeight: 340,
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
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: colors.warmWhite.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_border_rounded,
                      size: 20,
                      color: colors.charcoal,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saved "${destination.title}" to your profile!',
                          ),
                          backgroundColor: colors.charcoal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'destination-image-${destination.id}',
                    child: CachedNetworkImage(
                      imageUrl: destination.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: colors.cream),
                      errorWidget: (context, url, error) =>
                          Container(color: colors.charcoal),
                    ),
                  ),
                  // Dark bottom gradient for text contrast
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
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warmWhite.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${destination.rating} • Top Destination',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          destination.title,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.tagline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. EDITORIAL ARTICLE & TRAVEL INFO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Badges (Location & Entry Fee)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.warmWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.mutedBrown.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: colors.coral,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Region',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.mutedBrown,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${destination.cityOrRegency}, ${province.name}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.warmWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.mutedBrown.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 16,
                                    color: colors.teal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Entry Ticket',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.mutedBrown,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destination.entryFeeRange,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cultural Narrative & History
                  Text(
                    'About this Wonder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    destination.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 15,
                      color: colors.charcoal.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Geographic Coordinates Card (Ready for the Map Phase!)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.blueSubtle,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.blue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          color: colors.blue,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Geographical Coordinates',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.charcoal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Lat: ${destination.latitude.toStringAsFixed(4)}°, Long: ${destination.longitude.toStringAsFixed(4)}°',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.charcoal.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cultural Visitor Etiquette Callout
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.saffronSubtle,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.saffron.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.charcoal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cultural Etiquette & Tips',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.charcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'As sacred cultural heritage sites, visitors are encouraged to dress respectfully covering shoulders and knees. Traditional batik sarongs are often available at the entrance.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: colors.charcoal.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
