import 'package:flutter/material.dart';

/// Just Move It — Brand Color Palette
///
/// Palette Specification:
/// - Coral: #FF704F (Primary brand accent, main CTAs, active highlights)
/// - Saffron: #FFC857 (Secondary accent, culinary highlights, warm tags)
/// - Teal: #39A9A2 (Nature, cultural heritage tags, secondary actions)
/// - Blue: #5577C7 (Regional wayfinding, maritime/geographical accents)
/// - Cream: #F5EBD8 (Primary warm background canvas)
/// - Charcoal: #292B2A (High-contrast, readable text and primary contrast)
/// - Warm White: #FFFDF8 (Surface cards, modal dialogs, input fields)
/// - Muted Brown: #89745E (Subtle borders, secondary labels, divider lines)
class AppColors {
  // Brand Accents
  static const Color coral = Color(0xFFFF704F);
  static const Color saffron = Color(0xFFFFC857);
  static const Color teal = Color(0xFF39A9A2);
  static const Color blue = Color(0xFF5577C7);

  // Backgrounds & Canvas
  static const Color cream = Color(0xFFF5EBD8);
  static const Color warmWhite = Color(0xFFFFFDF8);

  // Neutrals & Text
  static const Color charcoal = Color(0xFF292B2A);
  static const Color mutedBrown = Color(0xFF89745E);

  // Editorial Tints (Subtle card backdrops & chip tags)
  static const Color coralSubtle = Color(0xFFFFF0EC);
  static const Color saffronSubtle = Color(0xFFFFF8E7);
  static const Color tealSubtle = Color(0xFFEAF6F5);
  static const Color blueSubtle = Color(0xFFEDF2FB);
}

/// [AppColorsExtension] enables type-safe, theme-aware brand color access in Flutter.
///
/// Usage anywhere in widget tree:
/// ```dart
/// final colors = context.appColors;
/// Container(color: colors.coral);
/// ```
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color coral;
  final Color saffron;
  final Color teal;
  final Color blue;
  final Color cream;
  final Color warmWhite;
  final Color charcoal;
  final Color mutedBrown;
  final Color coralSubtle;
  final Color saffronSubtle;
  final Color tealSubtle;
  final Color blueSubtle;

  const AppColorsExtension({
    required this.coral,
    required this.saffron,
    required this.teal,
    required this.blue,
    required this.cream,
    required this.warmWhite,
    required this.charcoal,
    required this.mutedBrown,
    required this.coralSubtle,
    required this.saffronSubtle,
    required this.tealSubtle,
    required this.blueSubtle,
  });

  /// Light theme default instance
  static const light = AppColorsExtension(
    coral: AppColors.coral,
    saffron: AppColors.saffron,
    teal: AppColors.teal,
    blue: AppColors.blue,
    cream: AppColors.cream,
    warmWhite: AppColors.warmWhite,
    charcoal: AppColors.charcoal,
    mutedBrown: AppColors.mutedBrown,
    coralSubtle: AppColors.coralSubtle,
    saffronSubtle: AppColors.saffronSubtle,
    tealSubtle: AppColors.tealSubtle,
    blueSubtle: AppColors.blueSubtle,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? coral,
    Color? saffron,
    Color? teal,
    Color? blue,
    Color? cream,
    Color? warmWhite,
    Color? charcoal,
    Color? mutedBrown,
    Color? coralSubtle,
    Color? saffronSubtle,
    Color? tealSubtle,
    Color? blueSubtle,
  }) {
    return AppColorsExtension(
      coral: coral ?? this.coral,
      saffron: saffron ?? this.saffron,
      teal: teal ?? this.teal,
      blue: blue ?? this.blue,
      cream: cream ?? this.cream,
      warmWhite: warmWhite ?? this.warmWhite,
      charcoal: charcoal ?? this.charcoal,
      mutedBrown: mutedBrown ?? this.mutedBrown,
      coralSubtle: coralSubtle ?? this.coralSubtle,
      saffronSubtle: saffronSubtle ?? this.saffronSubtle,
      tealSubtle: tealSubtle ?? this.tealSubtle,
      blueSubtle: blueSubtle ?? this.blueSubtle,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      coral: Color.lerp(coral, other.coral, t)!,
      saffron: Color.lerp(saffron, other.saffron, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      warmWhite: Color.lerp(warmWhite, other.warmWhite, t)!,
      charcoal: Color.lerp(charcoal, other.charcoal, t)!,
      mutedBrown: Color.lerp(mutedBrown, other.mutedBrown, t)!,
      coralSubtle: Color.lerp(coralSubtle, other.coralSubtle, t)!,
      saffronSubtle: Color.lerp(saffronSubtle, other.saffronSubtle, t)!,
      tealSubtle: Color.lerp(tealSubtle, other.tealSubtle, t)!,
      blueSubtle: Color.lerp(blueSubtle, other.blueSubtle, t)!,
    );
  }
}

/// Extension on [BuildContext] for ergonomic syntax:
/// `context.appColors.coral`
extension AppColorsX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
