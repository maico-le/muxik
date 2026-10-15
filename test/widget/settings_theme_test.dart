import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/core/theme/pixel_theme.dart';
import 'package:musical/core/theme/theme_provider.dart';
import 'package:musical/features/settings/settings_screen.dart';
import 'package:musical/core/providers/network_providers.dart';
import 'package:musical/core/providers/auth_providers.dart';
import 'package:musical/core/network/network_policy.dart';
import 'package:musical/audio/audio_cache_manager.dart';

class FakeNetworkPolicy extends NetworkPolicy {
  FakeNetworkPolicy() : super(autoListen: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen displays Theme & Color Scheme selector and handles clicks',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final fakePolicy = FakeNetworkPolicy();
    final themeNotifier = ThemeNotifier();
    final cacheManager = AudioCacheManager(db: db, maxCacheMb: 100);

    addTearDown(() async {
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => db),
          networkPolicyProvider.overrideWith((ref) => fakePolicy),
          audioCacheManagerProvider.overrideWith((ref) => cacheManager),
          dailyUsageHistoryProvider.overrideWith((ref) async => []),
          totalCacheSizeBytesProvider.overrideWith((ref) async => 1024 * 1024),
          activeAccountProvider.overrideWith((ref) async => null),
          appThemeProvider.overrideWith((ref) => themeNotifier),
        ],
        child: MaterialApp(
          theme: buildPixelThemeData(scheme: PixelThemeScheme.mistral, isDark: false),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Sections
    expect(find.text('GIAO DIỆN & MÀU SẮC (THEME & ACCENT)'), findsOneWidget);
    expect(find.text('TỰ ĐỘNG'), findsOneWidget);
    expect(find.text('SÁNG'), findsOneWidget);
    expect(find.text('TỐI'), findsOneWidget);

    expect(find.text('Mistral Orange'), findsOneWidget);
    expect(find.text('Spotify Green'), findsOneWidget);
    expect(find.text('Cyber Blue'), findsOneWidget);

    // Tap on SÁNG (Light)
    await tester.tap(find.text('SÁNG'));
    await tester.pumpAndSettle();
    expect(themeNotifier.state.mode, ThemeMode.light);

    // Tap on TỐI (Dark)
    await tester.tap(find.text('TỐI'));
    await tester.pumpAndSettle();
    expect(themeNotifier.state.mode, ThemeMode.dark);

    // Tap on Spotify Green
    await tester.tap(find.text('Spotify Green'));
    await tester.pumpAndSettle();
    expect(themeNotifier.state.scheme, PixelThemeScheme.spotify);

    // Tap on Cyber Blue
    await tester.tap(find.text('Cyber Blue'));
    await tester.pumpAndSettle();
    expect(themeNotifier.state.scheme, PixelThemeScheme.blue);
  });
}
