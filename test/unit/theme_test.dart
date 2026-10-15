import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musical/core/theme/pixel_theme.dart';
import 'package:musical/core/theme/theme_provider.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PixelTheme & Schemes Unit Tests', () {
    test('PixelThemeScheme properties and fromId resolver', () {
      expect(PixelThemeScheme.mistral.id, 'mistral');
      expect(PixelThemeScheme.spotify.id, 'spotify');
      expect(PixelThemeScheme.blue.id, 'blue');

      expect(PixelThemeScheme.spotify.displayName, 'Spotify Green');
      expect(PixelThemeScheme.spotify.previewPrimary, const Color(0xFF1DB954));

      expect(PixelThemeScheme.blue.displayName, 'Cyber Blue');
      expect(PixelThemeScheme.blue.previewPrimary, const Color(0xFF2563EB));

      expect(PixelThemeSchemeX.fromId('spotify'), PixelThemeScheme.spotify);
      expect(PixelThemeSchemeX.fromId('blue'), PixelThemeScheme.blue);
      expect(PixelThemeSchemeX.fromId('mistral'), PixelThemeScheme.mistral);
      expect(PixelThemeSchemeX.fromId('unknown'), PixelThemeScheme.mistral);
      expect(PixelThemeSchemeX.fromId(null), PixelThemeScheme.mistral);
    });

    test('PixelTheme.build instantiates correct palette for Mistral', () {
      final light = PixelTheme.build(scheme: PixelThemeScheme.mistral, isDark: false);
      expect(light.primary, const Color(0xFFFA520F));
      expect(light.background, const Color(0xFFFFFAEB));
      expect(light.border, const Color(0xFF000000));

      final dark = PixelTheme.build(scheme: PixelThemeScheme.mistral, isDark: true);
      expect(dark.primary, const Color(0xFFFA520F));
      expect(dark.background, const Color(0xFF121214));
    });

    test('PixelTheme.build instantiates correct palette for Spotify Green', () {
      final light = PixelTheme.build(scheme: PixelThemeScheme.spotify, isDark: false);
      expect(light.primary, const Color(0xFF1DB954));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.border, const Color(0xFF000000));

      final dark = PixelTheme.build(scheme: PixelThemeScheme.spotify, isDark: true);
      expect(dark.primary, const Color(0xFF1DB954));
      expect(dark.primaryHover, const Color(0xFF1ED760));
      expect(dark.background, const Color(0xFF121212));
      expect(dark.surface, const Color(0xFF181818));
      expect(dark.textPrimary, const Color(0xFFFFFFFF));
    });

    test('PixelTheme.build instantiates correct palette for Cyber Blue', () {
      final light = PixelTheme.build(scheme: PixelThemeScheme.blue, isDark: false);
      expect(light.primary, const Color(0xFF2563EB));
      expect(light.surface, const Color(0xFFFFFFFF));

      final dark = PixelTheme.build(scheme: PixelThemeScheme.blue, isDark: true);
      expect(dark.primary, const Color(0xFF3B82F6));
      expect(dark.background, const Color(0xFF0B1120));
      expect(dark.textPrimary, const Color(0xFFF8FAFC));
    });

    test('buildPixelThemeData creates consistent ThemeData and extensions', () {
      for (final scheme in PixelThemeScheme.values) {
        final lightTheme = buildPixelThemeData(scheme: scheme, isDark: false);
        final darkTheme = buildPixelThemeData(scheme: scheme, isDark: true);

        expect(lightTheme.brightness, Brightness.light);
        expect(darkTheme.brightness, Brightness.dark);
        expect(lightTheme.extension<PixelTheme>(), isNotNull);
        expect(darkTheme.extension<PixelTheme>(), isNotNull);
      }
    });

    test('PixelTheme copyWith and lerp functions properly', () {
      final original = PixelTheme.light();
      final modified = original.copyWith(borderWidth: 4.0);
      expect(modified.borderWidth, 4.0);
      expect(modified.primary, original.primary);

      final target = PixelTheme.dark();
      final lerped = original.lerp(target, 0.5);
      expect(lerped.borderWidth, original.borderWidth);
      expect(original.boxDecoration().border, isNotNull);
    });
  });

  group('ThemeNotifier & Controller Unit Tests', () {
    late MockSecureStorage mockStorage;
    final Map<String, String> inMemoryStore = {};

    setUp(() {
      inMemoryStore.clear();
      mockStorage = MockSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async => inMemoryStore[invocation.namedArguments[#key] as String]);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((invocation) async {
        inMemoryStore[invocation.namedArguments[#key] as String] = invocation.namedArguments[#value] as String;
      });
    });

    test('ThemeNotifier initial state defaults to system mode & mistral scheme', () {
      final notifier = ThemeNotifier(storage: mockStorage);
      expect(notifier.state.mode, ThemeMode.system);
      expect(notifier.state.scheme, PixelThemeScheme.mistral);
    });

    test('ThemeNotifier updates and persists ThemeMode', () async {
      final notifier = ThemeNotifier(storage: mockStorage);
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state.mode, ThemeMode.dark);
      expect(inMemoryStore['muxik_theme_mode'], 'dark');

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state.mode, ThemeMode.light);
      expect(inMemoryStore['muxik_theme_mode'], 'light');
    });

    test('ThemeNotifier updates and persists PixelThemeScheme (Spotify & Blue)', () async {
      final notifier = ThemeNotifier(storage: mockStorage);

      await notifier.setThemeScheme(PixelThemeScheme.spotify);
      expect(notifier.state.scheme, PixelThemeScheme.spotify);
      expect(inMemoryStore['muxik_theme_scheme'], 'spotify');

      await notifier.setThemeScheme(PixelThemeScheme.blue);
      expect(notifier.state.scheme, PixelThemeScheme.blue);
      expect(inMemoryStore['muxik_theme_scheme'], 'blue');
    });

    test('ThemeNotifier restores saved preferences on init', () async {
      inMemoryStore['muxik_theme_mode'] = 'dark';
      inMemoryStore['muxik_theme_scheme'] = 'spotify';

      final restoredNotifier = ThemeNotifier(storage: mockStorage);
      // Wait for async load to finish
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(restoredNotifier.state.mode, ThemeMode.dark);
      expect(restoredNotifier.state.scheme, PixelThemeScheme.spotify);
    });
  });
}
