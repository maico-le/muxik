import 'package:flutter/material.dart';
import '../../core/theme/pixel_theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEARCH'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: theme.boxDecoration(
                fillColor: theme.surface,
                hasShadow: true,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: theme.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'SEARCH SONGS, ARTISTS...',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Type a query to search YouTube Music',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
