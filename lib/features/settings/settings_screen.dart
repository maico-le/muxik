import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/providers/auth_providers.dart';
import '../auth/account_switcher_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Management Card
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    activeAccountAsync.when(
                      data: (acc) => acc != null
                          ? GestureDetector(
                              onTap: () => AccountSwitcherSheet.show(context),
                              child: Text(
                                'MANAGE',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: theme.amber,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                activeAccountAsync.when(
                  data: (account) {
                    if (account != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                Text(
                                  account.email,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PixelButton(
                            isSmall: true,
                            onPressed: () => context.push('/login'),
                            child: const Text('DETAILS'),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Not logged in (Guest mode)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        PixelButton(
                          isSmall: true,
                          isPrimary: true,
                          onPressed: () => context.push('/login'),
                          child: const Text('LOGIN'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text(
                    'Error: $err',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: theme.accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Data Saver Card
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATA SAVER',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Extreme cellular data saving (<25MB/h, Opus 48kbps, local LRU cache).',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Background Playback & Battery Optimization Card (Spec 9)
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BACKGROUND PLAYBACK',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Music keeps playing when your screen is locked or while using other apps.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: theme.amber.withValues(alpha: 0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BATTERY OPTIMIZATION NOTICE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Some manufacturers (Xiaomi, Samsung, Oppo, Huawei) aggressively terminate background services. To ensure non-stop background audio, disable battery optimization for Musical in your Android system settings.',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
