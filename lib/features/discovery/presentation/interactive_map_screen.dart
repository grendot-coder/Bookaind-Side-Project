import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';
import '../../../shared/repositories/cultural_repositories.dart';

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() =>
      _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  late final MapController _mapController;

  // Selected destination to show in the bottom preview card
  Destination? _selectedDestination;

  // Selected category filter: null = all
  String? _selectedCategory;

  // Initial center: Java Island / Archipelago center
  static final LatLng _indonesiaCenter = LatLng(-3.5000, 115.5000);
  static final LatLng _javaCenter = LatLng(-7.5000, 110.5000);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _moveToLocation(LatLng target, double zoom) {
    _mapController.move(target, zoom);
  }

  void _showLegendModal(BuildContext context, AppColorsExtension colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.mutedBrown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Map Marker Legend',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Differentiating Indonesian wonders by landscape & heritage type',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: colors.mutedBrown,
                  ),
                ),
                const SizedBox(height: 20),
                _LegendItem(
                  icon: Icons.account_balance_rounded,
                  color: colors.coral,
                  title: 'Cultural Heritage & Architecture',
                  subtitle: 'Temples, palaces, historic mosques, monuments',
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  icon: Icons.landscape_rounded,
                  color: colors.teal,
                  title: 'Nature & National Parks',
                  subtitle: 'Volcanic calderas, mountains, plateaus, wildlife sanctuaries',
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  icon: Icons.waves_rounded,
                  color: colors.blue,
                  title: 'Coastal & Marine Parks',
                  subtitle: 'Islands, coral reefs, beaches, marine reserves',
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  icon: Icons.holiday_village_rounded,
                  color: colors.saffron,
                  title: 'Traditional Villages',
                  subtitle: 'Living indigenous settlements, desa adat',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    // Watch Supabase live data
    final destinationsAsync = ref.watch(featuredDestinationsProvider);
    final provincesAsync = ref.watch(provincesProvider);

    final destinations =
        destinationsAsync.value ?? MockCulturalData.featuredDestinations;
    final provinces = provincesAsync.value ?? MockCulturalData.provinces;

    // Filter by selected category
    final filteredDestinations = destinations.where((d) {
      if (_selectedCategory == null) return true;
      return d.category.toLowerCase() == _selectedCategory;
    }).toList();

    final activeDestination =
        _selectedDestination ??
        (filteredDestinations.isNotEmpty ? filteredDestinations.first : null);

    return Scaffold(
      backgroundColor: colors.cream,
      body: Stack(
        children: [
          // 1. THE FLUTTER MAP TILE LAYER (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _javaCenter,
              initialZoom: 6.8,
              minZoom: 4.5,
              maxZoom: 16.0,
              onTap: (_, _) {
                // Tapping empty map area dismisses the preview card
                setState(() => _selectedDestination = null);
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bookaind',
              ),

              // Destination Markers Layer
              MarkerLayer(
                markers: filteredDestinations.map((destination) {
                  final isSelected = activeDestination?.id == destination.id;
                  final markerColor = destination.markerColor(colors);
                  final markerIcon = destination.categoryIcon;

                  return Marker(
                    point: LatLng(destination.latitude, destination.longitude),
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDestination = destination);
                        _moveToLocation(
                          LatLng(destination.latitude, destination.longitude),
                          10.5,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected ? markerColor : colors.warmWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : markerColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: markerColor.withValues(
                                alpha: isSelected ? 0.45 : 0.25,
                              ),
                              blurRadius: isSelected ? 10 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          markerIcon,
                          size: isSelected ? 26 : 22,
                          color: isSelected ? Colors.white : markerColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. TOP FLOATING APP BAR, CATEGORY FILTERS & PROVINCES
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back Button & Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.warmWhite.withValues(
                          alpha: 0.95,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: colors.charcoal,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warmWhite.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Nusantara Heritage Map',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => _showLegendModal(context, colors),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.coralSubtle,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 13,
                                        color: colors.coral,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Legend',
                                        style: TextStyle(
                                          color: colors.coral,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Filter Pills (Heritage, Nature, Marine, Village)
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _CategoryFilterChip(
                        label: 'All (${destinations.length})',
                        icon: Icons.explore_rounded,
                        accentColor: colors.charcoal,
                        isSelected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      _CategoryFilterChip(
                        label: 'Heritage & Candi',
                        icon: Icons.account_balance_rounded,
                        accentColor: colors.coral,
                        isSelected: _selectedCategory == 'structure',
                        onTap: () => setState(() => _selectedCategory = 'structure'),
                      ),
                      _CategoryFilterChip(
                        label: 'Nature & Parks',
                        icon: Icons.landscape_rounded,
                        accentColor: colors.teal,
                        isSelected: _selectedCategory == 'nature',
                        onTap: () => setState(() => _selectedCategory = 'nature'),
                      ),
                      _CategoryFilterChip(
                        label: 'Coastal & Marine',
                        icon: Icons.waves_rounded,
                        accentColor: colors.blue,
                        isSelected: _selectedCategory == 'marine',
                        onTap: () => setState(() => _selectedCategory = 'marine'),
                      ),
                      _CategoryFilterChip(
                        label: 'Traditional Villages',
                        icon: Icons.holiday_village_rounded,
                        accentColor: colors.saffron,
                        isSelected: _selectedCategory == 'village',
                        onTap: () => setState(() => _selectedCategory = 'village'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Horizontal Province Jump Pills
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // "All Indonesia" button
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          label: const Text('Indonesia View'),
                          backgroundColor: colors.warmWhite.withValues(alpha: 0.9),
                          side: BorderSide(
                            color: colors.coral.withValues(alpha: 0.35),
                          ),
                          onPressed: () => _moveToLocation(_indonesiaCenter, 5.0),
                        ),
                      ),
                      // Dynamic Province Pills
                      ...provinces.map((province) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ActionChip(
                            visualDensity: VisualDensity.compact,
                            label: Text(province.name),
                            backgroundColor: colors.warmWhite.withValues(alpha: 0.9),
                            side: BorderSide(
                              color: colors.mutedBrown.withValues(alpha: 0.18),
                            ),
                            onPressed: () {
                              _moveToLocation(
                                LatLng(province.latitude, province.longitude),
                                8.8,
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM FLOATING DESTINATION PREVIEW CARD
          if (activeDestination != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _DestinationMapCard(
                destination: activeDestination,
                onViewDetails: () {
                  context.push('/destination/${activeDestination.id}');
                },
                onClose: () {
                  setState(() => _selectedDestination = null);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Category filter chip in the top scrollable bar
class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : colors.warmWhite.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? accentColor : colors.mutedBrown.withValues(alpha: 0.2),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.charcoal,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legend item row in modal bottom sheet
class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.mutedBrown,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Floating bottom preview card for the selected destination on the map
class _DestinationMapCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onViewDetails;
  final VoidCallback onClose;

  const _DestinationMapCard({
    required this.destination,
    required this.onViewDetails,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.mutedBrown.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: destination.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: colors.cream),
                  errorWidget: (context, url, error) =>
                      Container(color: colors.charcoal),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Region
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: destination.markerSubtleColor(colors),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: destination
                                  .markerColor(colors)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                destination.categoryIcon,
                                size: 11,
                                color: destination.markerColor(colors),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination.categoryLabel,
                                style: TextStyle(
                                  color: destination.markerColor(colors),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: colors.mutedBrown,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            destination.cityOrRegency,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.mutedBrown,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: onClose,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.mutedBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      destination.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rating: ${destination.rating} ★ • ${destination.entryFeeRange}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // "View Travel Story" CTA Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: destination.markerColor(colors),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Travel Story & Guide'),
            ),
          ),
        ],
      ),
    );
  }
}
