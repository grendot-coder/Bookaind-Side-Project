import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  /// Callback when user taps "Start Exploring" or "Explore as Guest"
  final VoidCallback onStartExploring;

  /// Callback when user taps "Sign In"
  final VoidCallback onSignIn;

  const WelcomeScreen({
    super.key,
    required this.onStartExploring,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. FULL-BLEED EDITORIAL PHOTOGRAPHY
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=1400&auto=format&fit=crop',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            placeholder: (context, url) => Container(color: colors.charcoal),
            errorWidget: (context, url, error) => Container(
              color: colors.charcoal,
              child: const Center(
                child: Icon(
                  Icons.landscape_rounded,
                  size: 64,
                  color: Colors.white24,
                ),
              ),
            ),
          ),

          // 2. CINEMATIC MULTI-STOP GRADIENT OVERLAY (Guaranteed contrast, no floating cards)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.18, 0.45, 0.72, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.20),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.70),
                  Colors.black.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),

          // 3. EDITORIAL TOP BAR (No AI floating capsule pills)
          Positioned(
            top: topPadding + 14,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Mark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.coral,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BOOKAIND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),

                // Guest exploration bypass
                GestureDetector(
                  onTap: onStartExploring,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore as Guest',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. BOTTOM EDITORIAL CONTENT & TACTILE ACTIONS
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location Eyebrow with hairline rule (Publishing aesthetic)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 2,
                      color: colors.saffron,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BOROBUDUR • CENTRAL JAVA',
                      style: TextStyle(
                        color: colors.saffron,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Display Headline
                Text(
                  'Every Island\nTells a Story.',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    height: 1.08,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Narrative Subtitle
                Text(
                  'Unveil sacred candi, living traditions, and royal culinary recipes across the Indonesian archipelago.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),

                // Primary Action Button (Tactile 14px radius, not pill)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onStartExploring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.coral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Start Exploring',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary Sign In Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already an explorer? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: onSignIn,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: colors.saffron,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.saffron,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
