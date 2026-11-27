import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/itinerary_service.dart';
import '../../../core/services/local_settings_service.dart';
import '../../../shared/repositories/cultural_repositories.dart';
import '../../profile/presentation/widgets/profile_settings_sheet.dart';
import '../models/itinerary_model.dart';

class ItineraryPlannerScreen extends ConsumerStatefulWidget {
  final String? initialRegion;
  final ItineraryPlan? initialPlan;

  const ItineraryPlannerScreen({
    super.key,
    this.initialRegion,
    this.initialPlan,
  });

  @override
  ConsumerState<ItineraryPlannerScreen> createState() =>
      _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState extends ConsumerState<ItineraryPlannerScreen>
    with SingleTickerProviderStateMixin {
  // Wizard state: 0 = Input Form, 1 = Generating, 2 = Viewing Result
  int _viewState = 0;

  // Form selections
  late String _selectedRegion;
  final TextEditingController _customRegionController = TextEditingController();
  bool _useCustomRegion = false;

  int _selectedDuration = 3;
  String _selectedStyle = 'Deep Heritage & Ancient Temples';
  String _selectedBudget = 'Comfort Explorer';
  final TextEditingController _notesController = TextEditingController();

  // Generated Plan
  ItineraryPlan? _currentPlan;
  int _selectedDayIndex = 0;
  String? _fallbackNotice;

  // Loading animation state
  int _loadingTipIndex = 0;
  Timer? _loadingTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<String> _popularRegions = [
    'Yogyakarta & Solo',
    'Bali & Lombok',
    'East Java (Bromo & Majapahit)',
    'North Sumatra & Lake Toba',
    'West Java & Sunda Highlands',
    'Toraja & South Sulawesi',
    'Aceh & Gayo Heritage',
  ];

  static const List<String> _hiddenGems = [
    'Sumba Island',
    'Dieng Plateau',
    'Belitung Heritage',
    'Banyuwangi & Ijen',
    'Banda Neira',
  ];

  static const List<Map<String, dynamic>> _travelStyles = [
    {
      'title': 'Deep Heritage & Ancient Temples',
      'icon': Icons.temple_buddhist_rounded,
      'category': 'Archaeological Sites & Royal Courts',
      'desc': 'Focus on stone candi, royal kratons, and classical sacred architecture.',
    },
    {
      'title': 'Culinary & Living Crafts',
      'icon': Icons.restaurant_rounded,
      'category': 'Living Traditions & Street Markets',
      'desc': 'Batik workshops, ancestral night markets, and legendary hereditary warungs.',
    },
    {
      'title': 'Nature & Sacred Sanctuaries',
      'icon': Icons.forest_rounded,
      'category': 'Volcanic Trails & Holy Waters',
      'desc': 'Volcano sunrise trails, sacred lakes, and remote highland heritage villages.',
    },
    {
      'title': 'Relaxed & Family Friendly',
      'icon': Icons.family_restroom_rounded,
      'category': 'Comfort Pacing & All Generations',
      'desc': 'Gentle walking tempo with accessible, engaging cultural interactions for all ages.',
    },
  ];

  static const List<Map<String, dynamic>> _budgetTiers = [
    {
      'title': 'Authentic Culturalist',
      'icon': Icons.savings_outlined,
      'tag': 'Warungs & Community Stays',
      'desc': 'Traditional neighborhood warungs, village guesthouses, and local transit.',
    },
    {
      'title': 'Comfort Explorer',
      'icon': Icons.hotel_rounded,
      'tag': 'Curated Hotels & Private Rides',
      'desc': 'Boutique heritage lodgings, air-conditioned transfers, and guided site admissions.',
    },
    {
      'title': 'Royal Heritage & Luxury',
      'icon': Icons.workspace_premium_rounded,
      'tag': 'Private Historians & Premier Stays',
      'desc': 'Historic boutique villas, bespoke private scholar escorts, and VIP temple access.',
    },
  ];

  static const List<String> _noteSuggestions = [
    'Early morning sunrise focus',
    'Vegetarian culinary only',
    'Gentle walking for seniors',
    'Traditional textile & batik focus',
    'Sacred photography spots',
  ];

  static const List<String> _loadingQuotes = [
    'Consulting ancient chronicles, royal archives, and historical annals...',
    'Calibrating morning temple visits for contemplative tranquility and optimal light...',
    'Selecting hereditary artisan warungs and authentic culinary specialties...',
    'Reviewing temple etiquette, sacred perimeter customs, and ceremonial attire rules...',
    'Harmonizing transit routes across Nusantara heritage corridors...',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPlan != null) {
      _currentPlan = widget.initialPlan;
      _selectedRegion = widget.initialPlan!.region;
      _selectedDuration = widget.initialPlan!.durationDays.clamp(1, 14);
      _viewState = 2;
    } else {
      _selectedRegion = widget.initialRegion ?? _popularRegions.first;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _pulseController.dispose();
    _customRegionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _cancelGeneration() {
    _loadingTimer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _viewState = 0;
    });
  }

  void _startGeneration() async {
    HapticFeedback.mediumImpact();
    final region = _useCustomRegion && _customRegionController.text.trim().isNotEmpty
        ? _customRegionController.text.trim()
        : _selectedRegion;

    final request = ItineraryRequest(
      region: region,
      durationDays: _selectedDuration,
      travelStyle: _selectedStyle,
      budgetLevel: _selectedBudget,
      notes: _notesController.text.trim(),
    );

    setState(() {
      _viewState = 1;
      _loadingTipIndex = 0;
      _fallbackNotice = null;
    });

    _loadingTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) {
        setState(() {
          _loadingTipIndex = (_loadingTipIndex + 1) % _loadingQuotes.length;
        });
      }
    });

    try {
      final result =
          await ItineraryService.generateCulturalItineraryWithStatus(request);
      _loadingTimer?.cancel();
      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _currentPlan = result.plan;
          _fallbackNotice = result.fallbackNotice;
          _selectedDayIndex = 0;
          _viewState = 2;
        });
      }
    } catch (_) {
      _loadingTimer?.cancel();
      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() {
          _currentPlan = ItineraryPlan.createCuratedFallback(request);
          _fallbackNotice =
              'Showing curated offline heritage route.';
          _selectedDayIndex = 0;
          _viewState = 2;
        });
      }
    }
  }

  void _toggleSavePlan(AppColorsExtension colors) {
    final plan = _currentPlan;
    if (plan == null) return;
    HapticFeedback.mediumImpact();
    final saved = ref.read(savedItinerariesProvider.notifier).toggle(plan);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.charcoal,
        behavior: SnackBarBehavior.floating,
        content: Text(
          saved
              ? 'Itinerary saved to your Cultural Profile'
              : 'Itinerary removed from saved journeys',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _handleBackAction() {
    HapticFeedback.selectionClick();
    if (_viewState == 2 && widget.initialPlan == null) {
      setState(() => _viewState = 0);
    } else if (_viewState == 1) {
      _cancelGeneration();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final savedItineraries = ref.watch(savedItinerariesProvider);
    final bool isCurrentSaved = _currentPlan != null &&
        savedItineraries.any((p) => p.storageKey == _currentPlan!.storageKey);

    return PopScope(
      canPop: _viewState == 0 ||
          (_viewState == 2 && widget.initialPlan != null),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackAction();
      },
      child: Scaffold(
        backgroundColor: colors.cream,
        appBar: AppBar(
          backgroundColor: colors.cream,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.charcoal),
            tooltip: _viewState == 2 ? 'Return to Planner' : 'Back',
            onPressed: _handleBackAction,
          ),
          title: Text(
            _viewState == 2 ? 'Cultural Itinerary' : 'Nusantara Journey Architect',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.charcoal,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            if (_viewState == 0)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: _openByokSheet,
                  icon: Icon(
                    Icons.key_rounded,
                    size: 17,
                    color: colors.coral,
                  ),
                  label: Text(
                    ref.watch(aiSettingsProvider).hasApiKey
                        ? 'AI Key'
                        : 'Add AI Key',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.coral,
                    ),
                  ),
                ),
              ),
            if (_viewState == 2 && _currentPlan != null) ...[
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: colors.charcoal,
                  size: 22,
                ),
                tooltip: 'Copy Summary',
                onPressed: () {
                  final summary = '${_currentPlan!.title}\n\n'
                      'Region: ${_currentPlan!.region} (${_currentPlan!.durationDays} Days)\n'
                      'Summary: ${_currentPlan!.summary}\n\n'
                      'Curated with Bookaind Nusantara Cultural Guide.';
                  Clipboard.setData(ClipboardData(text: summary));
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: colors.charcoal,
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        'Itinerary summary copied to clipboard',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isCurrentSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isCurrentSaved ? colors.coral : colors.charcoal,
                  size: 24,
                ),
                tooltip: isCurrentSaved ? 'Saved' : 'Save Itinerary',
                onPressed: () => _toggleSavePlan(colors),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _viewState == 0
              ? _buildWizardView(theme, colors)
              : _viewState == 1
                  ? _buildLoadingView(theme, colors)
                  : _buildResultView(theme, colors, isCurrentSaved),
        ),
      ),
    );
  }

  void _openByokSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSettingsSheet(),
    );
  }

  // ==========================================
  // WIZARD VIEW (STATE 0)
  // ==========================================
  Widget _buildWizardView(ThemeData theme, AppColorsExtension colors) {
    final aiSettings = ref.watch(aiSettingsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          // Editorial Hero Header
          _buildEditorialHeader(theme, colors),
          const SizedBox(height: 16),

          // BYOK AI Status Banner (Prominent & One-Tap)
          _buildByokBanner(aiSettings, colors, theme),
          const SizedBox(height: 18),

          // STEP 1: Region Selection
          _buildStepCard(
            stepNumber: '01',
            title: 'Choose Nusantara Corridor',
            subtitle: 'Select a historic province or specify an island',
            colors: colors,
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularRegions.map((region) {
                    final isSelected = !_useCustomRegion && _selectedRegion == region;
                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label: '$region, destination choice',
                      child: ChoiceChip(
                        avatar: Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: isSelected ? Colors.white : colors.coral,
                        ),
                        label: Text(region),
                        selected: isSelected,
                        selectedColor: colors.coral,
                        backgroundColor: colors.warmWhite,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : colors.charcoal,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? colors.coral
                                : colors.mutedBrown.withValues(alpha: 0.25),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedRegion = region;
                              _useCustomRegion = false;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Toggle for custom island or regency
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _useCustomRegion = !_useCustomRegion);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          _useCustomRegion
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 18,
                          color: _useCustomRegion ? colors.coral : colors.mutedBrown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Type custom island, city, or cultural regency',
                            style: TextStyle(
                              fontSize: 13,
                              color: _useCustomRegion ? colors.coral : colors.charcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Animated Custom Region Input
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _useCustomRegion
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _customRegionController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sumba Island, Belitung, Dieng Plateau',
                            prefixIcon: Icon(
                              Icons.edit_location_alt_outlined,
                              color: colors.coral,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: colors.cream.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colors.coral),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colors.mutedBrown.withValues(alpha: 0.35),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colors.coral, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _hiddenGems.map((gem) {
                            return ActionChip(
                              label: Text(
                                gem,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.charcoal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: colors.warmWhite,
                              side: BorderSide(
                                color: colors.mutedBrown.withValues(alpha: 0.2),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _customRegionController.text = gem;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // STEP 2: Duration Stepper
          _buildStepCard(
            stepNumber: '02',
            title: 'Travel Duration',
            subtitle: 'Determine days of exploration (1 to 14 days)',
            colors: colors,
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fine-tune Stepper Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.cream.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.mutedBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$_selectedDuration',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.charcoal,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedDuration == 1 ? 'Day' : 'Days',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.mutedBrown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getDurationPacingHint(_selectedDuration),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.charcoal.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStepperButton(
                            icon: Icons.remove_rounded,
                            enabled: _selectedDuration > 1,
                            colors: colors,
                            onTap: () {
                              if (_selectedDuration > 1) {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedDuration--);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildStepperButton(
                            icon: Icons.add_rounded,
                            enabled: _selectedDuration < 14,
                            colors: colors,
                            onTap: () {
                              if (_selectedDuration < 14) {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedDuration++);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Presets
                Row(
                  children: [
                    _buildDurationChip(days: 2, label: '2D · Weekend', colors: colors),
                    const SizedBox(width: 6),
                    _buildDurationChip(days: 3, label: '3D · Highlights', colors: colors),
                    const SizedBox(width: 6),
                    _buildDurationChip(days: 5, label: '5D · Deep Dive', colors: colors),
                    const SizedBox(width: 6),
                    _buildDurationChip(days: 7, label: '7D · Grand Tour', colors: colors),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // STEP 3: Travel Focus
          _buildStepCard(
            stepNumber: '03',
            title: 'Primary Cultural Focus',
            subtitle: 'Select the guiding thread for your Nusantara itinerary',
            colors: colors,
            theme: theme,
            child: Column(
              children: _travelStyles.map((style) {
                final isSelected = _selectedStyle == style['title'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedStyle = style['title'] as String);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.coralSubtle
                            : colors.cream.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colors.coral
                              : colors.mutedBrown.withValues(alpha: 0.25),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.coral : colors.warmWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              style['icon'] as IconData,
                              color: isSelected ? Colors.white : colors.charcoal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? colors.coral : colors.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  style['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.charcoal.withValues(alpha: 0.75),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected ? colors.coral : colors.mutedBrown,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // STEP 4: Explorer Budget & Comfort Tier
          _buildStepCard(
            stepNumber: '04',
            title: 'Explorer Comfort & Tier',
            subtitle: 'Tailor transport, guide intensity, and culinary tier',
            colors: colors,
            theme: theme,
            child: Column(
              children: _budgetTiers.map((tier) {
                final isSelected = _selectedBudget == tier['title'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedBudget = tier['title'] as String);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.saffronSubtle
                            : colors.cream.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colors.saffron
                              : colors.mutedBrown.withValues(alpha: 0.25),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.saffron.withValues(alpha: 0.25)
                                  : colors.warmWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tier['icon'] as IconData,
                              color: colors.charcoal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        tier['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.charcoal.withValues(alpha: 0.75),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected ? colors.charcoal : colors.mutedBrown,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // STEP 5: Special Preferences
          _buildStepCard(
            stepNumber: '05',
            title: 'Custom Notes & Requirements',
            subtitle: 'Optional diet, pacing, or accessibility requirements',
            colors: colors,
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'e.g. Vegetarian culinary, senior pacing, early temple sunrise',
                    filled: true,
                    fillColor: colors.cream.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colors.mutedBrown.withValues(alpha: 0.25),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _noteSuggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.charcoal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: colors.warmWhite,
                      side: BorderSide(
                        color: colors.mutedBrown.withValues(alpha: 0.25),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final current = _notesController.text.trim();
                        if (current.isEmpty) {
                          _notesController.text = suggestion;
                        } else if (!current.contains(suggestion)) {
                          _notesController.text = '$current, $suggestion';
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Primary Submission CTA Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
              onPressed: _startGeneration,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Architect Cultural Itinerary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOADING VIEW (STATE 1)
  // ==========================================
  Widget _buildLoadingView(ThemeData theme, AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ambient Concentric Pulsing Cultural Halo
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110 + (_pulseAnimation.value * 20),
                      height: 110 + (_pulseAnimation.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.coral.withValues(
                          alpha: 0.08 * (1.0 - _pulseAnimation.value * 0.4),
                        ),
                      ),
                    ),
                    Container(
                      width: 86 + (_pulseAnimation.value * 12),
                      height: 86 + (_pulseAnimation.value * 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.saffron.withValues(
                          alpha: 0.15 * (1.0 - _pulseAnimation.value * 0.3),
                        ),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: colors.warmWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.coral.withValues(alpha: 0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.explore_rounded,
                          size: 32,
                          color: colors.coral,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),

            // Evocative Header
            Text(
              'BOOKAIND CULTURAL ENGINE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: colors.coral,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harmonizing Your Journey',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.charcoal,
              ),
            ),
            const SizedBox(height: 16),

            // Rotating Poetic Quotes
            SizedBox(
              height: 64,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _loadingQuotes[_loadingTipIndex],
                  key: ValueKey<int>(_loadingTipIndex),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.charcoal.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Cross-referencing historical annals, monument schedules & regional warungs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.mutedBrown,
              ),
            ),
            const SizedBox(height: 36),

            // Cancellation Affordance
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.charcoal,
                side: BorderSide(color: colors.mutedBrown.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _cancelGeneration,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Cancel & Adjust'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // RESULT VIEW (STATE 2)
  // ==========================================
  Widget _buildResultView(
    ThemeData theme,
    AppColorsExtension colors,
    bool isCurrentSaved,
  ) {
    final plan = _currentPlan;
    if (plan == null || plan.days.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: colors.mutedBrown),
            const SizedBox(height: 12),
            Text(
              'No cultural itinerary generated.',
              style: TextStyle(color: colors.charcoal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _viewState = 0),
              child: const Text('Return to Planner'),
            ),
          ],
        ),
      );
    }

    final activeDay = plan.days[_selectedDayIndex.clamp(0, plan.days.length - 1)];

    return Column(
      children: [
        // 1. Editorial Hero Summary Header Card
        Container(
          width: double.infinity,
          color: colors.warmWhite,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metadata Pills (No Emojis - Vector Icons)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetaPill(
                    icon: Icons.place_rounded,
                    label: plan.region,
                    color: colors.coral,
                    bgTint: colors.coralSubtle,
                  ),
                  _buildMetaPill(
                    icon: Icons.calendar_today_rounded,
                    label: '${plan.durationDays} Days',
                    color: colors.charcoal,
                    bgTint: colors.saffronSubtle,
                  ),
                  _buildMetaPill(
                    icon: Icons.explore_outlined,
                    label: _selectedStyle,
                    color: colors.teal,
                    bgTint: colors.tealSubtle,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                plan.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.charcoal,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                plan.summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.charcoal.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              if (_fallbackNotice != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.saffronSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.saffron.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: colors.charcoal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fallbackNotice!,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.charcoal,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.coral,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: const Size(48, 32),
                        ),
                        onPressed: _openByokSheet,
                        child: const Text(
                          'Set Key',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 2. Enriched Day Selector Tabs
        Container(
          height: 52,
          color: colors.warmWhite,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: plan.days.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDayIndex = index);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.charcoal : colors.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colors.charcoal
                          : colors.mutedBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Day ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? Colors.white : colors.charcoal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // 3. Day Theme Sub-Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: colors.cream,
          child: Row(
            children: [
              Icon(Icons.wb_twilight_rounded, size: 18, color: colors.coral),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Day ${activeDay.dayNumber} · ${activeDay.theme}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. True Vertical Timeline View of Activities
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 20, 24),
            itemCount: activeDay.activities.length + 1,
            itemBuilder: (context, index) {
              if (index < activeDay.activities.length) {
                final act = activeDay.activities[index];
                final isLast = index == activeDay.activities.length - 1;
                return _buildTimelineItem(
                  activity: act,
                  isLast: isLast,
                  index: index,
                  colors: colors,
                  theme: theme,
                );
              } else {
                return _buildTipsCard(plan.packingAndEtiquetteTips, colors, theme);
              }
            },
          ),
        ),

        // 5. Sticky Bottom Action Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colors.warmWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.charcoal,
                      side: BorderSide(color: colors.mutedBrown.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _viewState = 0);
                    },
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Adjust Request'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _toggleSavePlan(colors),
                    icon: Icon(
                      isCurrentSaved
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_rounded,
                      size: 18,
                    ),
                    label: Text(isCurrentSaved ? 'Saved to Profile' : 'Save Itinerary'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildByokBanner(
    AiSettingsState aiSettings,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    final hasKey = aiSettings.hasApiKey;
    return InkWell(
      onTap: _openByokSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasKey ? colors.tealSubtle : colors.saffronSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasKey
                ? colors.teal.withValues(alpha: 0.4)
                : colors.saffron.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasKey ? colors.teal : colors.charcoal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasKey ? Icons.auto_awesome_rounded : Icons.key_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasKey
                        ? 'Live AI Active · ${aiSettings.provider.shortLabel}'
                        : 'Offline Curated Mode (No AI Key)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasKey
                        ? 'Using your personal ${aiSettings.provider.shortLabel} key directly from this device.'
                        : 'Using built-in heritage routes. Tap to add a free Groq or Gemini key for live AI planning.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.charcoal.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  fontSize: 11,
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

  Widget _buildEditorialHeader(ThemeData theme, AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_outlined, size: 16, color: colors.coral),
            const SizedBox(width: 6),
            Text(
              'BOOKAIND INTELLIGENCE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: colors.coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Curate Your Heritage Odyssey',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.charcoal,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize your destination, duration, and pace. Our cultural engine structures each day with historical depth, sacred etiquette, and authentic culinary pairings.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.mutedBrown,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required AppColorsExtension colors,
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.mutedBrown.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.charcoal,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colors.mutedBrown,
              ),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required AppColorsExtension colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? colors.warmWhite : colors.cream,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? colors.mutedBrown.withValues(alpha: 0.3)
                  : colors.mutedBrown.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? colors.charcoal : colors.mutedBrown.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip({
    required int days,
    required String label,
    required AppColorsExtension colors,
  }) {
    final isSelected = _selectedDuration == days;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedDuration = days);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.charcoal : colors.warmWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? colors.charcoal
                  : colors.mutedBrown.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : colors.charcoal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDurationPacingHint(int days) {
    if (days <= 2) return 'Highlights tempo · Iconic landmarks';
    if (days <= 4) return 'Balanced tempo · Temples, arts & warungs';
    if (days <= 7) return 'Deep heritage · Multi-city cultural exploration';
    return 'Grand Nusantara expedition · Comprehensive heritage immersion';
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgTint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Vertical Timeline Rail with connected lines and nodes
  Widget _buildTimelineItem({
    required ItineraryActivity activity,
    required bool isLast,
    required int index,
    required AppColorsExtension colors,
    required ThemeData theme,
  }) {
    final Color nodeColor = index == 0
        ? colors.saffron
        : index == 1
            ? colors.coral
            : colors.blue;

    final IconData nodeIcon = index == 0
        ? Icons.wb_sunny_rounded
        : index == 1
            ? Icons.wb_cloudy_rounded
            : Icons.nights_stay_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column: Node Dot + Continuous Line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: nodeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: nodeColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(nodeIcon, size: 12, color: colors.charcoal),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colors.mutedBrown.withValues(alpha: 0.25),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Activity Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.warmWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.mutedBrown.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Slot Badge & Explore Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.charcoal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activity.timeSlot,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Accessible Touch Target Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.coral,
                          minimumSize: const Size(48, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.push(
                            '/search?q=${Uri.encodeComponent(activity.locationName)}',
                          );
                        },
                        icon: const Icon(Icons.north_east_rounded, size: 14),
                        label: const Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    activity.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.charcoal.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),

                  // Cultural Tip Pill
                  if (activity.culturalTip != null && activity.culturalTip!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.saffronSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.saffron.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colors.charcoal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activity.culturalTip!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.charcoal,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Culinary Spot Pill
                  if (activity.culinarySpot != null && activity.culinarySpot!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.coralSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.coral.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.restaurant_rounded,
                            size: 16,
                            color: colors.coral,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hereditary Dish: ${activity.culinarySpot}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.charcoal,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(
    List<String> tips,
    AppColorsExtension colors,
    ThemeData theme,
  ) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16, left: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tealSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.teal.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backpack_outlined, size: 18, color: colors.teal),
              const SizedBox(width: 8),
              Text(
                'Cultural Etiquette & Sacred Courtesies',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: colors.teal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.charcoal,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
