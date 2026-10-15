import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/library/library_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/playlist/playlist_detail_screen.dart';
import '../../features/player/mini_player.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pixel_icon.dart';
import '../providers/network_providers.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/library',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithPixelNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/playlist/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final playlistId = state.pathParameters['id'] ?? '';
        return PlaylistDetailScreen(playlistId: playlistId);
      },
    ),
  ],
);

/// Retro pixel navigation shell
class ScaffoldWithPixelNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithPixelNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/library')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/library');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final selectedIndex = _calculateSelectedIndex(context);
    final networkPolicy = ref.watch(networkPolicyProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (networkPolicy.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.black,
              alignment: Alignment.center,
              child: Text(
                '⚡ NGOẠI TUYẾN: PHÁT TỪ THƯ VIỆN & CACHE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.gold,
                ),
              ),
            ),
          const MiniPlayer(),
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                top: BorderSide(color: theme.border, width: theme.borderWidth),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _buildNavItem(
                context,
                index: 0,
                selectedIndex: selectedIndex,
                iconType: PixelIconType.queue,
                label: 'LIBRARY',
              ),
              _buildNavItem(
                context,
                index: 1,
                selectedIndex: selectedIndex,
                iconType: PixelIconType.search,
                label: 'SEARCH',
              ),
              _buildNavItem(
                context,
                index: 2,
                selectedIndex: selectedIndex,
                iconType: PixelIconType.settings,
                label: 'SETTINGS',
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int selectedIndex,
    required PixelIconType iconType,
    required String label,
  }) {
    final theme = context.pixelTheme;
    final isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index, context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: isSelected ? theme.primary.withValues(alpha: 0.15) : Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelIcon(
                iconType,
                size: 22,
                color: isSelected ? theme.primary : theme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.primary : theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
