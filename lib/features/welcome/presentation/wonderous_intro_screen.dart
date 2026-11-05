import 'package:flutter/material.dart';

/// Data model for each Wonderous intro slide
class IntroWonder {
  final String imagePath;
  final String title;
  final Color skyColor;

  const IntroWonder({
    required this.imagePath,
    required this.title,
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

  // The collection of Wonderous artworks!
  final List<IntroWonder> _wonders = const [
    IntroWonder(
      imagePath: 'assets/images/branding/istiqlal_hero.jpg',
      title: 'JUST MOVE IT • MASJID ISTIQLAL',
      skyColor: Color(0xFF6E8E7A), // Sage green sky
    ),
    IntroWonder(
      imagePath: 'assets/images/branding/sibea_bea_hero.jpg',
      title: 'JUST MOVE IT • BUKIT SIBEA-BEA',
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

            // 2. BOTTOM VIGNETTE (For contrast with prompt and dots)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 220,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),
            ),

            // 3. TOP EDITORIAL BRAND PILL
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF704F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          currentWonder.title,
                          key: ValueKey<String>(currentWonder.title),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. BOTTOM CONTROLS: DOT INDICATORS & "SWIPE UP" PROMPT
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_wonders.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Swipe up prompt
                  GestureDetector(
                    onTap: widget.onExplore,
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.55,
                        end: 1.0,
                      ).animate(_pulseController),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Swipe up to explore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
