import 'package:flutter/material.dart';

/// Available Pixel Theme Color Schemes
enum PixelThemeScheme {
  mistral,
  spotify,
  blue,
}

extension PixelThemeSchemeX on PixelThemeScheme {
  String get id {
    switch (this) {
      case PixelThemeScheme.mistral:
        return 'mistral';
      case PixelThemeScheme.spotify:
        return 'spotify';
      case PixelThemeScheme.blue:
        return 'blue';
    }
  }

  String get displayName {
    switch (this) {
      case PixelThemeScheme.mistral:
        return 'Mistral Orange';
      case PixelThemeScheme.spotify:
        return 'Spotify Green';
      case PixelThemeScheme.blue:
        return 'Cyber Blue';
    }
  }

  String get description {
    switch (this) {
      case PixelThemeScheme.mistral:
        return 'Cam Mistral ấm áp cổ điển (#FA520F)';
      case PixelThemeScheme.spotify:
        return 'Xanh lá Spotify đặc trưng (#1DB954)';
      case PixelThemeScheme.blue:
        return 'Xanh dương Cyber retro (#2563EB)';
    }
  }

  Color get previewPrimary {
    switch (this) {
      case PixelThemeScheme.mistral:
        return const Color(0xFFFA520F);
      case PixelThemeScheme.spotify:
        return const Color(0xFF1DB954);
      case PixelThemeScheme.blue:
        return const Color(0xFF2563EB);
    }
  }

  Color get previewSecondary {
    switch (this) {
      case PixelThemeScheme.mistral:
        return const Color(0xFFFFAF00);
      case PixelThemeScheme.spotify:
        return const Color(0xFF1ED760);
      case PixelThemeScheme.blue:
        return const Color(0xFF38BDF8);
    }
  }

  static PixelThemeScheme fromId(String? id) {
    switch (id) {
      case 'spotify':
        return PixelThemeScheme.spotify;
      case 'blue':
        return PixelThemeScheme.blue;
      case 'mistral':
      default:
        return PixelThemeScheme.mistral;
    }
  }
}

/// Retro pixel art theme palette and styling supporting multiple color schemes
@immutable
class PixelTheme extends ThemeExtension<PixelTheme> {
  // Brand colors
  final Color primary;
  final Color primaryHover;
  final Color amber;
  final Color gold;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGreen;
  final Color accentRed;

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

  /// Factory builder by scheme and dark/light mode
  factory PixelTheme.build({
    required PixelThemeScheme scheme,
    bool isDark = false,
  }) {
    switch (scheme) {
      case PixelThemeScheme.mistral:
        return PixelTheme.mistral(isDark: isDark);
      case PixelThemeScheme.spotify:
        return PixelTheme.spotify(isDark: isDark);
      case PixelThemeScheme.blue:
        return PixelTheme.blue(isDark: isDark);
    }
  }

  /// Mistral-inspired retro theme (Amber / Orange)
  factory PixelTheme.mistral({bool isDark = false}) {
    if (isDark) {
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

  /// Spotify-inspired retro theme (Iconic Spotify Green #1DB954)
  factory PixelTheme.spotify({bool isDark = false}) {
    if (isDark) {
      return const PixelTheme(
        primary: Color(0xFF1DB954),      // Spotify Green
        primaryHover: Color(0xFF1ED760), // Spotify Bright Green
        amber: Color(0xFF10B981),        // Mint accent
        gold: Color(0xFF34D399),         // Light Mint
        background: Color(0xFF121212),   // Spotify Dark Slate
        surface: Color(0xFF181818),      // Spotify Card Surface
        border: Color(0xFF282828),       // Charcoal Border
        textPrimary: Color(0xFFFFFFFF),
        textSecondary: Color(0xFFB3B3B3),
        accentGreen: Color(0xFF1ED760),
        accentRed: Color(0xFFEF4444),
        borderWidth: 2.0,
        shadowOffset: 3.0,
      );
    }
    return const PixelTheme(
      primary: Color(0xFF1DB954),      // Spotify Green
      primaryHover: Color(0xFF169C46), // Forest Green
      amber: Color(0xFF059669),        // Emerald
      gold: Color(0xFF10B981),         // Mint
      background: Color(0xFFF2FAF4),   // Pale Mint Tint
      surface: Color(0xFFFFFFFF),      // Pure White Card
      border: Color(0xFF000000),       // Hard Black Border
      textPrimary: Color(0xFF121212),
      textSecondary: Color(0xFF535353),
      accentGreen: Color(0xFF1DB954),
      accentRed: Color(0xFFEF4444),
      borderWidth: 2.0,
      shadowOffset: 3.0,
    );
  }

  /// Retro Cyber Blue theme (#2563EB / #38BDF8)
  factory PixelTheme.blue({bool isDark = false}) {
    if (isDark) {
      return const PixelTheme(
        primary: Color(0xFF3B82F6),      // Bright Cyber Blue
        primaryHover: Color(0xFF60A5FA), // Light Blue
        amber: Color(0xFF38BDF8),        // Sky Cyan
        gold: Color(0xFF93C5FD),         // Ice Blue
        background: Color(0xFF0B1120),   // Deep Midnight Navy
        surface: Color(0xFF151F32),      // Cyber Navy Card
        border: Color(0xFF1E293B),       // Slate Border
        textPrimary: Color(0xFFF8FAFC),
        textSecondary: Color(0xFF94A3B8),
        accentGreen: Color(0xFF10B981),
        accentRed: Color(0xFFEF4444),
        borderWidth: 2.0,
        shadowOffset: 3.0,
      );
    }
    return const PixelTheme(
      primary: Color(0xFF2563EB),      // Royal Blue
      primaryHover: Color(0xFF1D4ED8), // Deep Blue
      amber: Color(0xFF0284C7),        // Ocean Blue
      gold: Color(0xFF38BDF8),         // Sky Blue
      background: Color(0xFFF0F7FF),   // Ice Cream Pale Blue
      surface: Color(0xFFFFFFFF),      // Pure White Card
      border: Color(0xFF000000),       // Hard Black Border
      textPrimary: Color(0xFF0F172A),  // Navy Charcoal
      textSecondary: Color(0xFF475569),
      accentGreen: Color(0xFF10B981),
      accentRed: Color(0xFFEF4444),
      borderWidth: 2.0,
      shadowOffset: 3.0,
    );
  }

  /// Default light theme (Mistral)
  factory PixelTheme.light() => PixelTheme.mistral(isDark: false);

  /// Default dark theme (Mistral)
  factory PixelTheme.dark() => PixelTheme.mistral(isDark: true);

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
ThemeData buildPixelThemeData({
  PixelThemeScheme scheme = PixelThemeScheme.mistral,
  bool isDark = false,
}) {
  final pixelTheme = PixelTheme.build(scheme: scheme, isDark: isDark);

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: pixelTheme.background,
    fontFamily: 'monospace',
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: pixelTheme.primary,
      onPrimary: Colors.white,
      secondary: pixelTheme.amber,
      onSecondary: isDark ? Colors.white : Colors.black,
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
