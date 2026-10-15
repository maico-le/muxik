import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_icon.dart';
import '../../core/widgets/pixel_image.dart';
import '../../core/providers/auth_providers.dart';
import 'webview_login_screen.dart';
import 'dev_cookie_bottom_sheet.dart';
import 'account_switcher_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _handleCookieAuthentication(String cookie) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'VERIFYING CREDENTIALS...';
    });

    try {
      final repo = ref.read(accountRepoProvider);
      final accounts = await repo.authenticateWithCookie(cookie);
      ref.invalidate(activeAccountProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'SUCCESS! Logged in as ${accounts.first.name}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'ERROR: $e';
        });
      }
      rethrow;
    }
  }

  void _openWebViewLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewLoginScreen(
          onLoginSuccess: _handleCookieAuthentication,
        ),
      ),
    );
  }

  void _openDevCookieInput() {
    DevCookieBottomSheet.show(
      context,
      onSubmit: _handleCookieAuthentication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNT & AUTH'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Account Card
            activeAccountAsync.when(
              data: (account) {
                if (account != null) {
                  return PixelCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PixelImage(
                              imageUrl: account.thumbUrl,
                              width: 54,
                              height: 54,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: PixelButton(
                                isSmall: true,
                                onPressed: () => AccountSwitcherSheet.show(context),
                                child: const Text('SWITCH ACCOUNT'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PixelButton(
                                isSmall: true,
                                backgroundColor: theme.accentRed,
                                textColor: Colors.white,
                                onPressed: () async {
                                  await ref.read(accountRepoProvider).logout();
                                  ref.invalidate(activeAccountProvider);
                                },
                                child: const Text('LOGOUT'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // Guest state card
                return PixelCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      PixelIcon(
                        PixelIconType.settings,
                        size: 40,
                        color: theme.amber,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'NOT SIGNED IN',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to access your YouTube Music playlists, library, and personalized mixes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
            const SizedBox(height: 24),

            // Login Options
            PixelButton(
              isPrimary: true,
              onPressed: _isLoading ? null : _openWebViewLogin,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 8),
                  Text('SIGN IN WITH GOOGLE WEBVIEW'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PixelButton(
              backgroundColor: theme.amber,
              onPressed: _isLoading ? null : _openDevCookieInput,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code, size: 18),
                  SizedBox(width: 8),
                  Text('DEV MODE: ENTER COOKIE MANUALLY'),
                ],
              ),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              PixelCard(
                backgroundColor: theme.surface,
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusMessage!.startsWith('ERROR')
                        ? theme.accentRed
                        : theme.accentGreen,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: theme.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, size: 16, color: theme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'ZERO-SECRET COMMITMENT',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your session cookies are encrypted exclusively inside Android Keystore / FlutterSecureStorage and are never sent to third-party servers.',
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
    );
  }
}
