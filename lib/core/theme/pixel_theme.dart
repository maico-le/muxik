import 'package:flutter/material.dart';

/// Mistral-inspired retro pixel art theme palette and styling
@immutable
class PixelTheme extends ThemeExtension<PixelTheme> {
  // Brand colors
  final Color primary; // Mistral Orange #FA520F
  final Color primaryHover; // Bright Orange #FF8205
  final Color amber; // Amber #FFAF00
  final Color gold; // Gold #FFD800
  final Color background; // Warm Cream #FFFAEB / Dark Slate #18181B
  final Color surface; // Pure Cream #FFFDF7 / Dark Surface #27272A
  final Color border; // Hard Black #000000 / Light White #FFFFFF
  final Color textPrimary; // #1E1E1E / #FAFAFA
  final Color textSecondary; // #666666 / #A1A1AA
  final Color accentGreen; // Retro green for indicators
  final Color accentRed; // Retro red for errors

  // Geometry constants
  final double borderWidth;
  final double shadowOffset;

  const PixelTheme({
    required this.primary,
    required this.primaryHover,
    required this.amber,
    required this.gold,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGreen,
    required this.accentRed,
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
  });

  /// Light theme (Mistral.ai aesthetic)
  factory PixelTheme.light() {
    return const PixelTheme(
      primary: Color(0xFFFA520F),
      primaryHover: Color(0xFFFF8205),
      amber: Color(0xFFFFAF00),
      gold: Color(0xFFFFD800),
      background: Color(0xFFFFFAEB),
      surface: Color(0xFFFFFDF7),
      border: Color(0xFF000000),
      textPrimary: Color(0xFF1E1E1E),
      textSecondary: Color(0xFF666666),
      accentGreen: Color(0xFF22C55E),
      accentRed: Color(0xFFEF4444),
      borderWidth: 2.0,
      shadowOffset: 3.0,
    );
  }

  /// Dark theme
  factory PixelTheme.dark() {
    return const PixelTheme(
      primary: Color(0xFFFA520F),
      primaryHover: Color(0xFFFF8205),
      amber: Color(0xFFFFAF00),
      gold: Color(0xFFFFD800),
      background: Color(0xFF121214),
      surface: Color(0xFF1E1E22),
      border: Color(0xFF3F3F46),
      textPrimary: Color(0xFFFAFAFA),
      textSecondary: Color(0xFFA1A1AA),
      accentGreen: Color(0xFF22C55E),
      accentRed: Color(0xFFEF4444),
      borderWidth: 2.0,
      shadowOffset: 3.0,
    );
  }

  /// Box decoration for pixel card / button
  BoxDecoration boxDecoration({
    Color? fillColor,
    bool pressed = false,
    bool hasShadow = true,
    Color? customBorderColor,
  }) {
    return BoxDecoration(
      color: fillColor ?? surface,
      border: Border.all(
        color: customBorderColor ?? border,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.zero,
      boxShadow: (hasShadow && !pressed)
          ? [
              BoxShadow(
                color: border,
                offset: Offset(shadowOffset, shadowOffset),
                blurRadius: 0,
                spreadRadius: 0,
              )
            ]
          : null,
    );
  }

  @override
  PixelTheme copyWith({
    Color? primary,
    Color? primaryHover,
    Color? amber,
    Color? gold,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? accentGreen,
    Color? accentRed,
    double? borderWidth,
    double? shadowOffset,
  }) {
    return PixelTheme(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      amber: amber ?? this.amber,
      gold: gold ?? this.gold,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accentGreen: accentGreen ?? this.accentGreen,
      accentRed: accentRed ?? this.accentRed,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  @override
  PixelTheme lerp(ThemeExtension<PixelTheme>? other, double t) {
    if (other is! PixelTheme) return this;
    return PixelTheme(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
      gold: Color.lerp(gold, other.gold, t) ?? gold,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t) ?? accentGreen,
      accentRed: Color.lerp(accentRed, other.accentRed, t) ?? accentRed,
      borderWidth: (1 - t) * borderWidth + t * other.borderWidth,
      shadowOffset: (1 - t) * shadowOffset + t * other.shadowOffset,
    );
  }
}

/// Build Flutter ThemeData incorporating PixelTheme
ThemeData buildPixelThemeData({bool isDark = false}) {
  final pixelTheme = isDark ? PixelTheme.dark() : PixelTheme.light();

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: pixelTheme.background,
    fontFamily: 'monospace', // Default crisp monospace font fallback
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: pixelTheme.primary,
      onPrimary: Colors.white,
      secondary: pixelTheme.amber,
      onSecondary: Colors.black,
      error: pixelTheme.accentRed,
      onError: Colors.white,
      surface: pixelTheme.surface,
      onSurface: pixelTheme.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: pixelTheme.background,
      foregroundColor: pixelTheme.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: pixelTheme.textPrimary,
      ),
    ),
    extensions: [pixelTheme],
  );
}

/// Extension on BuildContext for quick access to PixelTheme
extension PixelThemeX on BuildContext {
  PixelTheme get pixelTheme =>
      Theme.of(this).extension<PixelTheme>() ?? PixelTheme.light();
}
