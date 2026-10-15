import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pixel_theme.dart';

/// State representing user's theme mode and accent color scheme
@immutable
class AppThemeState {
  final ThemeMode mode;
  final PixelThemeScheme scheme;

  const AppThemeState({
    this.mode = ThemeMode.system,
    this.scheme = PixelThemeScheme.mistral,
  });

  AppThemeState copyWith({
    ThemeMode? mode,
    PixelThemeScheme? scheme,
  }) {
    return AppThemeState(
      mode: mode ?? this.mode,
      scheme: scheme ?? this.scheme,
    );
  }
}

/// StateNotifier that persists theme settings to secure storage
class ThemeNotifier extends StateNotifier<AppThemeState> {
  final FlutterSecureStorage _storage;
  bool _hasUserChanged = false;

  static const _themeModeKey = 'muxik_theme_mode';
  static const _themeSchemeKey = 'muxik_theme_scheme';

  ThemeNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const AppThemeState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final savedModeStr = await _storage.read(key: _themeModeKey);
      final savedSchemeStr = await _storage.read(key: _themeSchemeKey);

      if (_hasUserChanged) return;

      ThemeMode mode = ThemeMode.system;
      if (savedModeStr == 'dark') {
        mode = ThemeMode.dark;
      } else if (savedModeStr == 'light') {
        mode = ThemeMode.light;
      }

      final scheme = PixelThemeSchemeX.fromId(savedSchemeStr);

      state = AppThemeState(mode: mode, scheme: scheme);
    } catch (_) {
      // Keep defaults if reading storage fails
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _hasUserChanged = true;
    state = state.copyWith(mode: mode);
    String modeStr = 'system';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    await _storage.write(key: _themeModeKey, value: modeStr);
  }

  Future<void> setThemeScheme(PixelThemeScheme scheme) async {
    _hasUserChanged = true;
    state = state.copyWith(scheme: scheme);
    await _storage.write(key: _themeSchemeKey, value: scheme.id);
  }
}

/// Provider for app theme state
final appThemeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeState>((ref) {
  return ThemeNotifier();
});
