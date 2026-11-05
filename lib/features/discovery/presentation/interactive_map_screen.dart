import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  late final MapController _mapController;

  // Selected destination to show in the bottom preview card
  Destination? _selectedDestination;

  // Initial center: Java Island
  static final LatLng _javaCenter = LatLng(-7.5000, 110.5000);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Default select the first destination
    _selectedDestination = MockCulturalData.featuredDestinations.first;
  }

  void _moveToLocation(LatLng target, double zoom) {
    _mapController.move(target, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final destinations = MockCulturalData.featuredDestinations;
    final provinces = MockCulturalData.provinces;

    return Scaffold(
      backgroundColor: colors.cream,
      body: Stack(
        children: [
          // 1. THE FLUTTER MAP TILE LAYER (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _javaCenter,
              initialZoom: 7.2,
              minZoom: 6.0,
              maxZoom: 16.0,
              onTap: (_, __) {
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
                markers: destinations.map((destination) {
                  final isSelected = _selectedDestination?.id == destination.id;
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
                          color: isSelected ? colors.coral : colors.warmWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : colors.coral,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.temple_buddhist_rounded,
                          size: isSelected ? 26 : 22,
                          color: isSelected ? Colors.white : colors.coral,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. TOP FLOATING APP BAR & REGION SELECTOR
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Bar with Back Button
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
                          child: Text(
                            'Java Cultural Map',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Province Jump Pills
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // "All Java" button
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: const Text('All Java'),
                          backgroundColor: colors.warmWhite,
                          side: BorderSide(
                            color: colors.coral.withValues(alpha: 0.4),
                          ),
                          onPressed: () => _moveToLocation(_javaCenter, 7.2),
                        ),
                      ),
                      // Dynamic Province Pills
                      ...provinces.map((province) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(province.name),
                            backgroundColor: colors.warmWhite,
                            side: BorderSide(
                              color: colors.mutedBrown.withValues(alpha: 0.2),
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
          if (_selectedDestination != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _DestinationMapCard(
                destination: _selectedDestination!,
                onViewDetails: () {
                  context.push('/destination/${_selectedDestination!.id}');
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
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colors.coral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.cityOrRegency,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.coral,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
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
                    const SizedBox(height: 4),
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
                backgroundColor: colors.coral,
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
