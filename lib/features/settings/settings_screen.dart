import 'package:flutter/material.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                const Text(
                  'Mode: Save Data (Opus ~48kbps on Cellular)',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Not logged in (Guest mode)',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
