import 'package:flutter/material.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';

/// Pixel art bottom sheet for manual cookie input (Dev Mode / fallback testing)
class DevCookieBottomSheet extends StatefulWidget {
  final Future<void> Function(String cookie) onSubmit;

  const DevCookieBottomSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(String cookie) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: DevCookieBottomSheet(onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<DevCookieBottomSheet> createState() => _DevCookieBottomSheetState();
}

class _DevCookieBottomSheetState extends State<DevCookieBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final cookie = _controller.text.trim();
    if (cookie.isEmpty) {
      setState(() => _errorMessage = 'PLEASE ENTER A COOKIE STRING');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(cookie);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

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
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.amber,
              border: Border.all(color: theme.border, width: theme.borderWidth),
            ),
            child: Row(
              children: [
                Text(
                  'DEV MODE: COOKIE INPUT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 18, color: theme.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Paste your YouTube Music session cookie string containing SAPISID or __Secure-3PAPISID to test without Google WebView:',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Input box
          Container(
            decoration: theme.boxDecoration(fillColor: theme.surface),
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: theme.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. SAPISID=xxxx; __Secure-3PAPISID=yyyy; ...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.accentRed,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PixelButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 12),
              PixelButton(
                isPrimary: true,
                onPressed: _isLoading ? null : _handleSubmit,
                child: Text(_isLoading ? 'VERIFYING...' : 'SAVE & APPLY'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
