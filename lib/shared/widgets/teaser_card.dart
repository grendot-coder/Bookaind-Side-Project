import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Teaser card for the upcoming Interactive Map
class MapTeaserCard extends StatelessWidget {
  final VoidCallback onTap;

  const MapTeaserCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.tealSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Java on the Map',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Locate temples, batik artisans, and heritage trails geographically.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.charcoal.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Teaser card for the AI Discovery Assistant
class AiAssistantTeaserCard extends StatelessWidget {
  final VoidCallback onTap;

  const AiAssistantTeaserCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.coralSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.coral.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.coral,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Cultural Guide',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ask about historical context, etiquette, or personalized itineraries.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.charcoal.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: colors.coral,
            ),
          ),
        ],
      ),
    );
  }
}
