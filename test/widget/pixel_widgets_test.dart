import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musical/core/theme/pixel_theme.dart';
import 'package:musical/core/widgets/pixel_widgets.dart';
import 'package:musical/core/widgets/pixel_icon.dart';
import 'package:musical/core/widgets/pixel_dialog.dart';

void main() {
  group('Pixel UI Components & Theme Tests', () {
    testWidgets('PixelButton renders and reacts to tap events', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPixelThemeData(isDark: false),
          home: Scaffold(
            body: Center(
              child: PixelButton(
                onPressed: () => tapped = true,
                child: const Text('RETRO PLAY'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('RETRO PLAY'), findsOneWidget);
      await tester.tap(find.text('RETRO PLAY'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('PixelCard renders child with 0-radius box decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPixelThemeData(isDark: false),
          home: const Scaffold(
            body: PixelCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('PixelProgressBar renders discrete segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPixelThemeData(isDark: false),
          home: const Scaffold(
            body: PixelProgressBar(
              value: 0.5,
              segments: 10,
            ),
          ),
        ),
      );

      expect(find.byType(PixelProgressBar), findsOneWidget);
    });

    testWidgets('PixelIcon renders CustomPaint without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPixelThemeData(isDark: false),
          home: const Scaffold(
            body: Column(
              children: [
                PixelIcon(PixelIconType.play),
                PixelIcon(PixelIconType.pause),
                PixelIcon(PixelIconType.next),
                PixelIcon(PixelIconType.prev),
                PixelIcon(PixelIconType.shuffle),
                PixelIcon(PixelIconType.loopAll),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PixelIcon), findsNWidgets(6));
    });

    testWidgets('PixelSwitch toggles state on tap', (tester) async {
      var isSwitched = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: buildPixelThemeData(isDark: false),
              home: Scaffold(
                body: PixelSwitch(
                  value: isSwitched,
                  onChanged: (val) => setState(() => isSwitched = val),
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(PixelSwitch), findsOneWidget);
      await tester.tap(find.byType(PixelSwitch));
      await tester.pumpAndSettle();
      expect(isSwitched, isTrue);
    });
  });
}
