import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/local_settings_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../shared/repositories/cultural_repositories.dart';
import '../../discovery/models/itinerary_model.dart';
import 'widgets/profile_settings_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  User? _currentUser;
  late final StreamSubscription<AuthState> _authSubscription;

  // 0 = Saved Heritage, 1 = Saved Journeys
  int _selectedLibraryTab = 0;

  static const List<String> _allPassionTopics = [
    'Batik & Weaving',
    'Ancient Candi',
    'Royal Keraton',
    'Traditional Culinary',
    'Gamelan & Music',
    'Wayang Heritage',
    'Volcanic Sanctuaries',
    'Coastal & Spice Islands',
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = SupabaseAuthService.currentUser;
    _authSubscription = SupabaseAuthService.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _currentUser = data.session?.user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _openSettingsSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSettingsSheet(),
    );
  }

  void _openEditPassionsDialog(
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final activePassions = ref.watch(culturalPassionsProvider);
            return AlertDialog(
              backgroundColor: colors.warmWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                'Edit Cultural Passions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.charcoal,
                ),
              ),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPassionTopics.map((topic) {
                  final selected = activePassions.contains(topic);
                  return FilterChip(
                    selected: selected,
                    label: Text(topic),
                    selectedColor: colors.teal,
                    backgroundColor: colors.cream,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : colors.charcoal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selected
                            ? colors.teal
                            : colors.mutedBrown.withValues(alpha: 0.25),
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(culturalPassionsProvider.notifier)
                          .togglePassion(topic);
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: colors.coral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final bookmarks = ref.watch(bookmarksProvider);
    final savedItineraries = ref.watch(savedItinerariesProvider);
    final passions = ref.watch(culturalPassionsProvider);
    final aiSettings = ref.watch(aiSettingsProvider);

    final user = _currentUser;
    final bool isSignedIn = user != null;
    final String fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final String displayName = fullName.isNotEmpty
        ? fullName
        : (user?.email?.split('@').first ?? 'Nusantara Explorer');

    return Scaffold(
      backgroundColor: colors.cream,
      appBar: AppBar(
        backgroundColor: colors.cream,
        elevation: 0,
        title: Text(
          'Explorer Dossier',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.charcoal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.charcoal),
            tooltip: 'Settings & AI Key',
            onPressed: _openSettingsSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // 1. EDITORIAL IDENTITY & METRICS CARD
          _buildIdentityHeader(
            theme: theme,
            colors: colors,
            displayName: displayName,
            subtitle: isSignedIn
                ? (user.email ?? 'Cloud Sync Active')
                : 'Local-First Heritage Journal',
            isSignedIn: isSignedIn,
            bookmarksCount: bookmarks.length,
            itinerariesCount: savedItineraries.length,
            passionsCount: passions.length,
          ),
          const SizedBox(height: 14),

          // 2. PROMINENT BYOK AI ENGINE CARD
          _buildByokCard(
            aiSettings: aiSettings,
            colors: colors,
            theme: theme,
          ),
          const SizedBox(height: 18),

          // 3. SEGMENTED LIBRARY TABS (Saved Heritage | Saved Journeys)
          _buildSegmentedTabs(
            colors: colors,
            bookmarksCount: bookmarks.length,
            itinerariesCount: savedItineraries.length,
          ),
          const SizedBox(height: 14),

          if (_selectedLibraryTab == 0)
            _buildBookmarksSection(bookmarks, colors, theme)
          else
            _buildItinerariesSection(savedItineraries, colors, theme),

          const SizedBox(height: 22),

          // 3. INTERACTIVE CULTURAL PASSIONS
          _buildPassionsSection(passions, colors, theme),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader({
    required ThemeData theme,
    required AppColorsExtension colors,
    required String displayName,
    required String subtitle,
    required bool isSignedIn,
    required int bookmarksCount,
    required int itinerariesCount,
    required int passionsCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.mutedBrown.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSignedIn ? colors.coral : colors.coralSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.coral.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.explore_rounded,
                  size: 28,
                  color: isSignedIn ? Colors.white : colors.coral,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.mutedBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.mutedBrown.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 14),

          // 3-Column Metrics Strip
          Row(
            children: [
              _buildStatCell(
                value: '$bookmarksCount',
                label: 'Saved Spots',
                colors: colors,
                theme: theme,
              ),
              _buildVerticalDivider(colors),
              _buildStatCell(
                value: '$itinerariesCount',
                label: 'Journeys',
                colors: colors,
                theme: theme,
              ),
              _buildVerticalDivider(colors),
              _buildStatCell(
                value: '$passionsCount',
                label: 'Passions',
                colors: colors,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildByokCard({
    required AiSettingsState aiSettings,
    required AppColorsExtension colors,
    required ThemeData theme,
  }) {
    final hasKey = aiSettings.hasApiKey;
    return InkWell(
      onTap: _openSettingsSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasKey ? colors.tealSubtle : colors.saffronSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasKey
                ? colors.teal.withValues(alpha: 0.4)
                : colors.saffron.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasKey ? colors.teal : colors.charcoal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasKey ? Icons.auto_awesome_rounded : Icons.key_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasKey
                        ? 'BYOK AI Active · ${aiSettings.provider.shortLabel}'
                        : 'Bring Your Own AI Key (BYOK)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasKey
                        ? 'Private API key saved on device. Tap to switch provider or test connection.'
                        : 'Unlock live AI chat and custom itineraries using your own free Groq or Gemini key.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.charcoal.withValues(alpha: 0.8),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.warmWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.mutedBrown.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                hasKey ? 'Manage' : 'Add Key',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hasKey ? colors.teal : colors.coral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCell({
    required String value,
    required String label,
    required AppColorsExtension colors,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.mutedBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(AppColorsExtension colors) {
    return Container(
      width: 1,
      height: 28,
      color: colors.mutedBrown.withValues(alpha: 0.2),
    );
  }

  Widget _buildSegmentedTabs({
    required AppColorsExtension colors,
    required int bookmarksCount,
    required int itinerariesCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.mutedBrown.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          _buildSegmentButton(
            index: 0,
            label: 'Saved Heritage ($bookmarksCount)',
            icon: Icons.bookmark_outline_rounded,
            colors: colors,
          ),
          _buildSegmentButton(
            index: 1,
            label: 'Saved Journeys ($itinerariesCount)',
            icon: Icons.route_rounded,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required IconData icon,
    required AppColorsExtension colors,
  }) {
    final isSelected = _selectedLibraryTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedLibraryTab = index);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.charcoal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : colors.mutedBrown,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colors.charcoal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksSection(
    List<BookmarkItem> bookmarks,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    if (bookmarks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.mutedBrown.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 38,
              color: colors.mutedBrown,
            ),
            const SizedBox(height: 10),
            Text(
              'No saved heritage yet',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bookmark monuments, villages, or culinary traditions to access them offline anytime.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.mutedBrown,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.go('/discover'),
              icon: const Icon(Icons.explore_outlined, size: 16),
              label: const Text('Explore Catalog'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final item = bookmarks[index];
        return InkWell(
          onTap: () => context.push(item.routePath),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.warmWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.mutedBrown.withValues(alpha: 0.18),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: colors.cream),
                          errorWidget: (_, _, _) => Container(
                            color: colors.coralSubtle,
                            child: Icon(item.icon, color: colors.coral),
                          ),
                        )
                      else
                        Container(
                          color: colors.coralSubtle,
                          child: Icon(item.icon, color: colors.coral, size: 32),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(bookmarksProvider.notifier)
                                  .removeById(item.id);
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.mutedBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItinerariesSection(
    List<ItineraryPlan> itineraries,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    if (itineraries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.mutedBrown.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.route_outlined,
              size: 38,
              color: colors.mutedBrown,
            ),
            const SizedBox(height: 10),
            Text(
              'No saved itineraries yet',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Generate a cultural route in the Journey Architect and save it for offline travel reference.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.mutedBrown,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.push('/itinerary-planner'),
              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: const Text('Architect a Journey'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: itineraries.map((plan) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => context.push('/itinerary-planner', extra: plan),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.warmWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.mutedBrown.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.coralSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          plan.region,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colors.coral,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.saffronSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${plan.durationDays} Days',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colors.charcoal,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: colors.mutedBrown,
                        ),
                        tooltip: 'Remove itinerary',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(savedItinerariesProvider.notifier)
                              .remove(plan.storageKey);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedBrown,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPassionsSection(
    List<String> passions,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.mutedBrown.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cultural Passions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.charcoal,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: colors.coral,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                onPressed: () => _openEditPassionsDialog(colors, theme),
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any topic to search matching heritage entries',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.mutedBrown,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: passions.map((interest) {
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/search?q=${Uri.encodeComponent(interest)}');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.tealSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.north_east_rounded,
                        size: 12,
                        color: colors.teal,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
