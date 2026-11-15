import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  /// Callback when the user taps "Start Exploring" (Guest bypass)
  final VoidCallback onStartExploring;

  /// Callback when the user taps "Sign In"
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
                  Icons.temple_buddhist,
                  size: 64,
                  color: Colors.white38,
                ),
              ),
            ),
          ),

          // 2. CINEMATIC MULTI-STOP GRADIENT OVERLAY
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25, 0.5, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),

          // 3. TOP BRANDING PILL
          Positioned(
            top: topPadding + 16,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BOOKAIND • NUSANTARA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. BOTTOM EDITORIAL CONTENT & ACTIONS
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location eyebrow badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: colors.saffron,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'BOROBUDUR, CENTRAL JAVA',
                      style: TextStyle(
                        color: colors.saffron,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bold Magazine Display
                Text(
                  'Every Island\nTells a Different Story.',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.12,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Unveil sacred candi, royal culinary arts, and living heritage across the archipelago.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onStartExploring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Start Exploring',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: TextButton(
                    onPressed: onSignIn,
                    child: RichText(
                      text: TextSpan(
                        text: 'Already a member? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: colors.saffron,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.saffron,
                            ),
                          ),
                        ],
                      ),
                    ),
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
