import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The persistent shell widget with a floating pill navigation bar.
/// `StatefulNavigationShell` from go_router keeps tab state alive.
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingPillNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _FloatingPillNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingPillNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
    (icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Discover'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF292B2A), // Charcoal
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72,
                height: 64,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? 44 : 40,
                    height: isSelected ? 44 : 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
