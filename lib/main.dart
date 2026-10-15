import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/pixel_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'core/providers/player_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MusicalApp(),
    ),
  );
}

class MusicalApp extends ConsumerWidget {
  const MusicalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep background audio handler active across app lifecycle
    ref.watch(audioHandlerProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'Muxik - Retro Pixel Audio',
      debugShowCheckedModeBanner: false,
      theme: buildPixelThemeData(scheme: appTheme.scheme, isDark: false),
      darkTheme: buildPixelThemeData(scheme: appTheme.scheme, isDark: true),
      themeMode: appTheme.mode,
      routerConfig: appRouter,
    );
  }
}
