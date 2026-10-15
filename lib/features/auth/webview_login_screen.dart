import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../data/yt/yt_client.dart';

/// InAppWebView Login Screen capturing YouTube Music session cookies
class WebViewLoginScreen extends StatefulWidget {
  final Future<void> Function(String cookie) onLoginSuccess;

  const WebViewLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<WebViewLoginScreen> createState() => _WebViewLoginScreenState();
}

class _WebViewLoginScreenState extends State<WebViewLoginScreen> {
  InAppWebViewController? _webViewController;
  CookieManager? _cookieManager;
  bool _isLoading = true;
  String? _statusText;

  static const String loginUrl =
      'https://accounts.google.com/ServiceLogin?ltmpl=music&service=youtube&uilel=3&passive=true&continue=https%3A%2F%2Fwww.youtube.com%2Fsignin%3Faction_handle_signin%3Dtrue%26app%3Ddesktop%26hl%3Den%26next%3Dhttps%253A%252F%252Fmusic.youtube.com%252F%26feature%3D__FEATURE__&hl=en';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _cookieManager = CookieManager.instance();
      _clearWebViewCookies();
    }
  }

  Future<void> _clearWebViewCookies() async {
    try {
      await _cookieManager?.deleteAllCookies();
    } catch (_) {}
  }

  Future<void> _checkAndExtractCookies(WebUri? currentUri) async {
    if (currentUri == null) return;
    final urlStr = currentUri.toString();

    // Check if redirected to YouTube Music main page
    if (urlStr.startsWith('https://music.youtube.com')) {
      setState(() {
        _isLoading = true;
        _statusText = 'EXTRACTING SESSION COOKIES...';
      });

      try {
        final cookies = await _cookieManager?.getCookies(
          url: WebUri('https://music.youtube.com/'),
        );

        if (cookies != null && cookies.isNotEmpty) {
          final cookieHeader =
              cookies.map((c) => '${c.name}=${c.value}').join('; ');

          final sapisid = YtClient.extractCookie(cookieHeader, 'SAPISID') ??
              YtClient.extractCookie(cookieHeader, '__Secure-3PAPISID');

          if (sapisid != null && sapisid.isNotEmpty) {
            setState(() => _statusText = 'AUTHENTICATING...');
            await widget.onLoginSuccess(cookieHeader);

            // Wipe WebView session cookies for privacy
            await _clearWebViewCookies();

            if (mounted) {
              Navigator.of(context).pop(true);
            }
            return;
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _statusText = 'AUTH FAILED: $e';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GOOGLE LOGIN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(loginUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              cacheEnabled: false,
              clearCache: true,
              userAgent:
                  'Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              await _checkAndExtractCookies(url);
            },
          ),
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PixelProgressBar(
                value: 0.6,
                height: 4,
                barColor: theme.primary,
              ),
            ),
          if (_statusText != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: PixelCard(
                backgroundColor: theme.amber,
                child: Text(
                  _statusText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
