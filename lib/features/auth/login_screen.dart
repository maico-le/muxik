import 'package:flutter/material.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RETRO LOGIN',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign in to access your YouTube Music library and playlists.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 24),
              PixelButton(
                isPrimary: true,
                onPressed: () {},
                child: const Text('SIGN IN WITH GOOGLE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
