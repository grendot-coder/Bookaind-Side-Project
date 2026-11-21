import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/models/cultural_model.dart';
import '../../../shared/repositories/cultural_repositories.dart';

enum SearchFilterTab {
  all('All', Icons.auto_awesome),
  destinations('Destinations', Icons.landscape_rounded),
  culture('Culinary & Arts', Icons.restaurant_rounded),
  provinces('Provinces', Icons.map_rounded);

  final String label;
  final IconData icon;
  const SearchFilterTab(this.label, this.icon);
}

class _SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String tagLabel;
  final IconData tagIcon;
  final Color tagColor;
  final Color tagBgColor;
  final String routePath;
  final SearchFilterTab tab;

  const _SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.tagLabel,
    required this.tagIcon,
    required this.tagColor,
    required this.tagBgColor,
    required this.routePath,
    required this.tab,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _query = '';
  SearchFilterTab _activeTab = SearchFilterTab.all;

  // Popular search suggestions for quick discovery
  static const _popularSuggestions = [
    'Mount Bromo',
    'Bakso Malang',
    'Borobudur',
    'Baluran',
    'Batik Tulis',
    'Gudeg',
    'Wae Rebo',
    'Prambanan',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _controller = TextEditingController(text: _query);
    _focusNode = FocusNode();

    // Auto focus textfield when entering search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _query = '');
    _focusNode.requestFocus();
  }

  void _applySuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    setState(() => _query = suggestion);
  }

  List<_SearchResultItem> _buildResults({
    required List<Destination> destinations,
    required List<CulturalEntry> culturalEntries,
    required List<Province> provinces,
    required AppColorsExtension colors,
  }) {
    final cleanQuery = _query.trim().toLowerCase();
    final List<_SearchResultItem> allItems = [];

    // 1. Destinations
    for (final d in destinations) {
      final matchesQuery =
          cleanQuery.isEmpty ||
          d.title.toLowerCase().contains(cleanQuery) ||
          d.cityOrRegency.toLowerCase().contains(cleanQuery) ||
          d.tagline.toLowerCase().contains(cleanQuery) ||
          d.categoryLabel.toLowerCase().contains(cleanQuery) ||
          d.category.toLowerCase().contains(cleanQuery) ||
          (cleanQuery == 'nature' && d.category == 'nature') ||
          (cleanQuery == 'candi' && d.category == 'structure');

      if (matchesQuery) {
        allItems.add(
          _SearchResultItem(
            id: d.id,
            title: d.title,
            subtitle: '${d.cityOrRegency} • ${d.tagline}',
            imageUrl: d.imageUrl,
            tagLabel: d.categoryLabel,
            tagIcon: d.categoryIcon,
            tagColor: d.markerColor(colors),
            tagBgColor: d.markerSubtleColor(colors),
            routePath: '/destination/${d.id}',
            tab: SearchFilterTab.destinations,
          ),
        );
      }
    }

    // 2. Cultural & Culinary Entries
    for (final c in culturalEntries) {
      final matchesQuery =
          cleanQuery.isEmpty ||
          c.title.toLowerCase().contains(cleanQuery) ||
          c.localName.toLowerCase().contains(cleanQuery) ||
          c.summary.toLowerCase().contains(cleanQuery) ||
          c.categoryId.toLowerCase().contains(cleanQuery) ||
          (cleanQuery == 'food' && c.categoryId == 'food') ||
          (cleanQuery == 'makanan' && c.categoryId == 'food') ||
          (cleanQuery == 'kuliner' && c.categoryId == 'food');

      if (matchesQuery) {
        final isFood = c.categoryId == 'food';
        allItems.add(
          _SearchResultItem(
            id: c.id,
            title: c.title,
            subtitle: c.localName.isNotEmpty
                ? '${c.localName} • ${c.summary}'
                : c.summary,
            imageUrl: c.imageUrl,
            tagLabel: isFood ? 'Culinary' : 'Tradition',
            tagIcon: isFood ? Icons.restaurant : Icons.palette_rounded,
            tagColor: isFood ? colors.coral : colors.saffron,
            tagBgColor: isFood ? colors.coralSubtle : colors.saffronSubtle,
            routePath: '/cultural/${c.id}',
            tab: SearchFilterTab.culture,
          ),
        );
      }
    }

    // 3. Provinces
    for (final p in provinces) {
      final matchesQuery =
          cleanQuery.isEmpty ||
          p.name.toLowerCase().contains(cleanQuery) ||
          p.localName.toLowerCase().contains(cleanQuery) ||
          p.capital.toLowerCase().contains(cleanQuery) ||
          p.tagline.toLowerCase().contains(cleanQuery);

      if (matchesQuery) {
        allItems.add(
          _SearchResultItem(
            id: p.id,
            title: p.name,
            subtitle: 'Capital: ${p.capital} • ${p.tagline}',
            imageUrl: p.heroImageUrl,
            tagLabel: 'Province',
            tagIcon: Icons.map_rounded,
            tagColor: colors.teal,
            tagBgColor: colors.tealSubtle,
            routePath: '/province/${p.id}',
            tab: SearchFilterTab.provinces,
          ),
        );
      }
    }

    // Apply active filter tab
    if (_activeTab == SearchFilterTab.all) {
      return allItems;
    }
    return allItems.where((item) => item.tab == _activeTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final destinationsAsync = ref.watch(allDestinationsProvider);
    final culturalAsync = ref.watch(culturalEntriesProvider);
    final provincesAsync = ref.watch(provincesProvider);

    final destinations = destinationsAsync.value ?? [];
    final culturalEntries = culturalAsync.value ?? [];
    final provinces = provincesAsync.value ?? [];

    final results = _buildResults(
      destinations: destinations,
      culturalEntries: culturalEntries,
      provinces: provinces,
      colors: colors,
    );

    return Scaffold(
      backgroundColor: colors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP SEARCH BAR ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colors.charcoal,
                      size: 20,
                    ),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),

                  // Floating Search Pill Input
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.warmWhite,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onQueryChanged,
                        textInputAction: TextInputAction.search,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search temples, food, nature...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.mutedBrown.withValues(alpha: 0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colors.coral,
                            size: 22,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: colors.mutedBrown,
                                  ),
                                  splashRadius: 18,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. FILTER TABS (All, Destinations, Culinary, Provinces)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: SearchFilterTab.values.map((tab) {
                  final isSelected = _activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) => setState(() => _activeTab = tab),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 14,
                            color: isSelected ? Colors.white : colors.charcoal,
                          ),
                          const SizedBox(width: 6),
                          Text(tab.label),
                        ],
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colors.charcoal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      selectedColor: colors.coral,
                      backgroundColor: colors.warmWhite,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? colors.coral
                              : colors.mutedBrown.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // 3. MAIN CONTENT: Suggestions or Results List
            Expanded(
              child: _query.isEmpty
                  ? _buildInitialSuggestionsView(colors: colors, theme: theme)
                  : _buildResultsListView(
                      results: results,
                      colors: colors,
                      theme: theme,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// When search query is empty: popular search chips
  Widget _buildInitialSuggestionsView({
    required AppColorsExtension colors,
    required ThemeData theme,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(
          'POPULAR EXPLORATIONS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.coral,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _popularSuggestions.map((suggestion) {
            return InkWell(
              onTap: () => _applySuggestion(suggestion),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.warmWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.mutedBrown.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: colors.coral,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      suggestion,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 36),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: colors.mutedBrown.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 12),
              Text(
                'Type any temple, dish, or island above',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.mutedBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Results list view
  Widget _buildResultsListView({
    required List<_SearchResultItem> results,
    required AppColorsExtension colors,
    required ThemeData theme,
  }) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: colors.mutedBrown.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No heritage found for "$_query"',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching with broader terms like Bromo, Batik, or Bakso.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.mutedBrown,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colors.warmWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(item.routePath),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  Container(color: colors.cream),
                              errorWidget: (_, _, _) => Container(
                                color: colors.charcoal,
                                child: Icon(
                                  item.tagIcon,
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          : Container(
                              color: colors.cream,
                              child: Icon(item.tagIcon, color: item.tagColor),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Texts & Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.tagBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.tagIcon,
                                size: 11,
                                color: item.tagColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.tagLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: item.tagColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Title
                        Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.mutedBrown,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Trailing Chevron
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colors.mutedBrown.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
