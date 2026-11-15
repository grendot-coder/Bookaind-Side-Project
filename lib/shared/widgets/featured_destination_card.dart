import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/models/cultural_model.dart';

class FeaturedDestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const FeaturedDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final categoryColor = destination.markerColor(colors);
    final categorySubtle = destination.markerSubtleColor(colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed hero image
            CachedNetworkImage(
              imageUrl: destination.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: colors.cream),
              errorWidget: (context, url, error) => Container(
                color: colors.charcoal,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
            ),

            // Dark gradient overlay — bottom 40% of card
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.42, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),

            // Category badge — top left
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: categorySubtle.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      destination.categoryIcon,
                      size: 13,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      destination.categoryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Rating pill — top right
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.warmWhite.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      destination.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom overlay — location + title + CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location eyebrow
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            destination.cityOrRegency,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Destination title
                    Text(
                      destination.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Explore CTA pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            destination.tagline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colors.coral,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
