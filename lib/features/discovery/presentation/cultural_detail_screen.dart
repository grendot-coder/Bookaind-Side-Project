import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';

class CulturalDetailScreen extends ConsumerWidget {
  final String culturalId;

  const CulturalDetailScreen({super.key, required this.culturalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Look up entry from mock data
    final entry = MockCulturalData.culturalEntries.firstWhere(
      (e) => e.id == culturalId,
      orElse: () => MockCulturalData.culturalEntries.first,
    );

    return Scaffold(
      backgroundColor: colors.cream,
      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING HERO APPBAR
          SliverAppBar(
            expandedHeight: 320,
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
                            'Saved "${entry.title}" to your profile!',
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
                    tag: 'cultural-image-${entry.id}',
                    child: Image.network(
                      entry.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) =>
                          Container(color: colors.charcoal),
                    ),
                  ),
                  // Dark bottom gradient for text legibility
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.isUnescoRecognized)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.teal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'UNESCO INTANGIBLE HERITAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        Text(
                          entry.title,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.localName,
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

          // 2. ARTICLE CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Callout Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.warmWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.mutedBrown.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      entry.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: colors.charcoal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cultural Narrative Section
                  Text(
                    'History & Cultural Significance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 15,
                      color: colors.charcoal.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Regional Association
                  Text(
                    'Associated Java Regions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: entry.provinceIds.map((pId) {
                      final provinceName = MockCulturalData.provinces
                          .firstWhere(
                            (p) => p.id == pId,
                            orElse: () => MockCulturalData.provinces.first,
                          )
                          .name;
                      return Chip(
                        avatar: Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: colors.coral,
                        ),
                        label: Text(provinceName),
                        backgroundColor: colors.warmWhite,
                        side: BorderSide(
                          color: colors.mutedBrown.withValues(alpha: 0.2),
                        ),
                      );
                    }).toList(),
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
