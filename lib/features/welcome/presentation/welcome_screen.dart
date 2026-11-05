import 'package:flutter/material.dart';
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: colors.cream,
      body: SafeArea(
        top: false, // Let the photography bleed smoothly into the status bar
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HERO PHOTOGRAPHY CONTAINER (Top 55% of the screen)
                  SizedBox(
                    height: size.height * 0.55,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image with smooth rounded bottom corners
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=1200&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colors.charcoal,
                                child: const Center(
                                  child: Icon(
                                    Icons.temple_buddhist,
                                    size: 64,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Subtle dark gradient overlay at the bottom of the photo for depth
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Editorial Pill Badge
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 20,
                          left: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.warmWhite.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colors.mutedBrown.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.coral,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'BOOKAIND • JAVA HERITAGE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.charcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Photo Caption / Location Tag
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Borobudur, Central Java',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. EDITORIAL CONTENT & CALL TO ACTIONS (Bottom 45%)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // Expressive Headline
                          Text(
                            'Discover the Living Soul of Indonesia.',
                            style: theme.textTheme.displayMedium?.copyWith(
                              height: 1.15,
                              color: colors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Editorial Subtitle
                          Text(
                            'Unveil ancient royal temples, culinary secrets, and timeless craft traditions of Java—curated for modern discovery.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.charcoal.withValues(alpha: 0.8),
                              height: 1.45,
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 20),

                          // Primary Action: Start Exploring (Public Guest Access)
                          SizedBox(
                            width: 400,
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
                                children: [
                                  Text(
                                    'Start Exploring',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Secondary Action: Sign In
                          Center(
                            child: TextButton(
                              onPressed: onSignIn,
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already a Jelajeer? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.mutedBrown,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: colors.charcoal,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
