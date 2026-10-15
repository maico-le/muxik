import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/providers/auth_providers.dart';

/// Pixel art account switcher dialog/sheet
class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AccountSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final repo = ref.watch(accountRepoProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(
          top: BorderSide(color: theme.border, width: theme.borderWidth),
          left: BorderSide(color: theme.border, width: theme.borderWidth),
          right: BorderSide(color: theme.border, width: theme.borderWidth),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary,
              border: Border.all(color: theme.border, width: theme.borderWidth),
            ),
            child: Row(
              children: [
                const Text(
                  'SWITCH ACCOUNT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No accounts saved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: theme.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final isCurrent = account.isUsed;

                  return PixelCard(
                    backgroundColor: isCurrent
                        ? theme.amber.withValues(alpha: 0.2)
                        : theme.surface,
                    onTap: isCurrent
                        ? null
                        : () async {
                            await repo.switchAccount(account.email);
                            ref.invalidate(activeAccountProvider);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    child: Row(
                      children: [
                        PixelImage(
                          imageUrl: account.thumbUrl,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                              if (account.pageId != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Brand Channel (${account.email})',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(
                                  account.email,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              border: Border.all(color: theme.border, width: 1),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              'Error loading accounts: $err',
              style: TextStyle(
                fontFamily: 'monospace',
                color: theme.accentRed,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PixelButton(
            backgroundColor: theme.accentRed,
            textColor: Colors.white,
            onPressed: () async {
              await repo.logout();
              ref.invalidate(activeAccountProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('LOGOUT & CLEAR DATA'),
          ),
        ],
      ),
    );
  }
}
