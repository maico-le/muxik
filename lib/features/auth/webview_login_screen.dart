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

  static const String youtubeMusicUrl = 'https://music.youtube.com/';
  static const String directGoogleLoginUrl =
      'https://accounts.google.com/ServiceLogin?service=youtube&passive=true&continue=https%3A%2F%2Fmusic.youtube.com%2F&hl=vi';

  // Standard clean mobile Chrome user-agent without embedded WebView (; wv) flags
  static const String mobileChromeUserAgent =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _cookieManager = CookieManager.instance();
    }
  }

  Future<void> _checkAndExtractCookies([WebUri? currentUri]) async {
    final uri = currentUri ?? await _webViewController?.getUrl();
    if (uri == null) return;
    final urlStr = uri.toString();

    // Check if redirected to YouTube Music or YouTube main page
    final isMusicOrYt = urlStr.contains('music.youtube.com') ||
        urlStr.contains('youtube.com/signin') ||
        urlStr.contains('youtube.com');

    final isGoogleAuthPage = urlStr.contains('accounts.google.com/signin') ||
        urlStr.contains('accounts.google.com/v3/signin') ||
        urlStr.contains('accounts.google.com/ServiceLogin');

    if (isMusicOrYt && !isGoogleAuthPage) {
      setState(() {
        _isLoading = true;
        _statusText = 'EXTRACTING SESSION COOKIES...';
      });

      try {
        final musicCookies = await _cookieManager?.getCookies(
              url: WebUri('https://music.youtube.com/'),
            ) ??
            [];
        final ytCookies = await _cookieManager?.getCookies(
              url: WebUri('https://www.youtube.com/'),
            ) ??
            [];
        final googleCookies = await _cookieManager?.getCookies(
              url: WebUri('https://accounts.google.com/'),
            ) ??
            [];

        final allCookiesMap = <String, String>{};
        for (final c in [...googleCookies, ...ytCookies, ...musicCookies]) {
          allCookiesMap[c.name] = c.value;
        }

        if (allCookiesMap.isNotEmpty) {
          final cookieHeader =
              allCookiesMap.entries.map((e) => '${e.key}=${e.value}').join('; ');

          final sapisid = YtClient.extractCookie(cookieHeader, 'SAPISID') ??
              YtClient.extractCookie(cookieHeader, '__Secure-3PAPISID') ??
              YtClient.extractCookie(cookieHeader, 'SID');

          if (sapisid != null && sapisid.isNotEmpty) {
            setState(() => _statusText = 'AUTHENTICATING...');
            await widget.onLoginSuccess(cookieHeader);

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
            tooltip: 'Lấy cookie ngay',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _checkAndExtractCookies(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: theme.surface,
            onSelected: (val) {
              if (val == 'ytmusic') {
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(youtubeMusicUrl)),
                );
              } else if (val == 'direct') {
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(directGoogleLoginUrl)),
                );
              } else if (val == 'reload') {
                _webViewController?.reload();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'ytmusic',
                child: Text('Trang chủ YouTube Music',
                    style: TextStyle(fontFamily: 'monospace', color: theme.textPrimary, fontSize: 12)),
              ),
              PopupMenuItem(
                value: 'direct',
                child: Text('Đến trang đăng nhập Google',
                    style: TextStyle(fontFamily: 'monospace', color: theme.textPrimary, fontSize: 12)),
              ),
              PopupMenuItem(
                value: 'reload',
                child: Text('Tải lại trang',
                    style: TextStyle(fontFamily: 'monospace', color: theme.textPrimary, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(youtubeMusicUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              cacheEnabled: true,
              clearCache: false,
              thirdPartyCookiesEnabled: true,
              userAgent: mobileChromeUserAgent,
              preferredContentMode: UserPreferredContentMode.RECOMMENDED,
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
            onUpdateVisitedHistory: (controller, url, isReload) async {
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
