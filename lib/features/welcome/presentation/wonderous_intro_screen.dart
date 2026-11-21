import 'package:flutter/material.dart';

/// Data model for each Wonderous intro slide
class IntroWonder {
  final String imagePath;
  final String title;
  final String location;
  final Color skyColor;

  const IntroWonder({
    required this.imagePath,
    required this.title,
    required this.location,
    required this.skyColor,
  });
}

class WonderousIntroScreen extends StatefulWidget {
  final VoidCallback onExplore;

  const WonderousIntroScreen({super.key, required this.onExplore});

  @override
  State<WonderousIntroScreen> createState() => _WonderousIntroScreenState();
}

class _WonderousIntroScreenState extends State<WonderousIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final PageController _pageController;
  int _currentPage = 0;

  // The collection of Wonderous artworks
  final List<IntroWonder> _wonders = const [
    IntroWonder(
      imagePath: 'assets/images/branding/istiqlal_hero.jpg',
      title: 'MASJID ISTIQLAL',
      location: 'JAKARTA • ARCHITECTURE OF UNITY',
      skyColor: Color(0xFF6E8E7A), // Sage green sky
    ),
    IntroWonder(
      imagePath: 'assets/images/branding/sibea_bea_hero.jpg',
      title: 'BUKIT SIBEA-BEA',
      location: 'SAMOSIR • LAKE TOBA PANORAMA',
      skyColor: Color(0xFFF0655D), // Coral red sky
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWonder = _wonders[_currentPage];
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: currentWonder.skyColor,
      body: GestureDetector(
        // Detect swipe up anywhere on screen
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            widget.onExplore();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. HORIZONTAL CAROUSEL FOR ARTWORK
            PageView.builder(
              controller: _pageController,
              itemCount: _wonders.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final wonder = _wonders[index];
                return Image.asset(
                  wonder.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                );
              },
            ),

            // 2. MULTI-STOP VIGNETTES (For top and bottom typographic contrast)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 260,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. EDITORIAL TOP BAR (Publishing aesthetics, no floating pill)
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
                          color: const Color(0xFFFF704F),
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

                  // Skip to Welcome
                  GestureDetector(
                    onTap: widget.onExplore,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. BOTTOM EDITORIAL DISPLAY & SWIPE UP PROMPT
            Positioned(
              bottom: bottomPadding + 24,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Location Eyebrow
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<String>(currentWonder.title),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              color: const Color(0xFFFFC857),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentWonder.location,
                              style: const TextStyle(
                                color: Color(0xFFFFC857),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentWonder.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Minimalist Dash Indicators (not rounded capsule pills)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_wonders.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 26 : 8,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),

                  // Swipe up / Tap Prompt
                  GestureDetector(
                    onTap: widget.onExplore,
                    behavior: HitTestBehavior.opaque,
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.6,
                        end: 1.0,
                      ).animate(_pulseController),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Swipe up or tap to explore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
