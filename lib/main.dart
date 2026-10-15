import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/pixel_theme.dart';
import 'core/routing/app_router.dart';

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
    return MaterialApp.router(
      title: 'Musical - Retro Pixel Audio',
      debugShowCheckedModeBanner: false,
      theme: buildPixelThemeData(isDark: false),
      darkTheme: buildPixelThemeData(isDark: true),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
