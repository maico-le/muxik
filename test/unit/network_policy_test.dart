import 'package:flutter_test/flutter_test.dart';
import 'package:musical/core/network/network_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 8 - NetworkPolicy Unit Tests', () {
    test('Default policy state on Wi-Fi', () {
      final policy = NetworkPolicy(initialNetwork: NetworkType.wifi, autoListen: false);

      expect(policy.isWifi, isTrue);
      expect(policy.isCellular, isFalse);
      expect(policy.isOffline, isFalse);
      expect(policy.effectiveMode, equals(DataSaverMode.highQuality));
      expect(policy.shouldPreferLowBitrate, isFalse);
      expect(policy.shouldLoadThumbnails, isTrue);
      expect(policy.shouldPrefetch, isTrue);
      expect(policy.shouldAllowSync, isTrue);
    });

    test('Cellular network engages data saving policy', () {
      final policy = NetworkPolicy(initialNetwork: NetworkType.cellular, autoListen: false);

      expect(policy.isCellular, isTrue);
      expect(policy.isWifi, isFalse);
      expect(policy.effectiveMode, equals(DataSaverMode.saving));
      expect(policy.shouldPreferLowBitrate, isTrue); // Lowest acceptable Opus/AAC ~48kbps
      expect(policy.shouldLoadThumbnails, isTrue);
      expect(policy.shouldPrefetch, isFalse); // wifiOnlyForPrefetch is true by default
      expect(policy.shouldAllowSync, isFalse); // wifiOnlyForSync is true by default
    });

    test('Metered Wi-Fi is treated as cellular hotspot (Spec 7.1)', () {
      final policy = NetworkPolicy(
        initialNetwork: NetworkType.wifi,
        isMetered: true,
        autoListen: false,
      );

      expect(policy.isCellular, isTrue);
      expect(policy.isWifi, isFalse);
      expect(policy.effectiveMode, equals(DataSaverMode.saving));
      expect(policy.shouldPreferLowBitrate, isTrue);
    });

    test('Super Data Saver overrides everything (<20MB/hour)', () {
      final policy = NetworkPolicy(initialNetwork: NetworkType.wifi, autoListen: false);
      policy.setSuperSaverEnabled(true);

      expect(policy.effectiveMode, equals(DataSaverMode.superSaver));
      expect(policy.shouldPreferLowBitrate, isTrue);
      expect(policy.shouldLoadThumbnails, isFalse); // Block image downloads
      expect(policy.shouldPrefetch, isFalse); // Block prefetching
    });

    test('Monthly cellular cap exceeded auto triggers Super Data Saver (Spec 7.6)', () {
      final policy = NetworkPolicy(initialNetwork: NetworkType.cellular, autoListen: false);
      policy.setMonthlyDataCapMb(500);
      policy.setAutoSuperSaverOnCap(true);

      // Usage under 500MB
      policy.updateCurrentMonthCellularBytes(400 * 1024 * 1024);
      expect(policy.isCapExceeded, isFalse);
      expect(policy.effectiveMode, equals(DataSaverMode.saving));

      // Usage exceeds 500MB
      policy.updateCurrentMonthCellularBytes(501 * 1024 * 1024);
      expect(policy.isCapExceeded, isTrue);
      expect(policy.effectiveMode, equals(DataSaverMode.superSaver));
      expect(policy.shouldLoadThumbnails, isFalse);
      expect(policy.shouldPrefetch, isFalse);
    });

    test('Custom policy mutators update effectively and notify listeners', () {
      final policy = NetworkPolicy(initialNetwork: NetworkType.cellular, autoListen: false);
      var notifications = 0;
      policy.addListener(() => notifications++);

      policy.setCellularMode(DataSaverMode.balanced);
      expect(policy.cellularMode, equals(DataSaverMode.balanced));
      expect(policy.effectiveMode, equals(DataSaverMode.balanced));
      expect(policy.shouldPreferLowBitrate, isFalse);

      policy.setWifiOnlyForSync(false);
      expect(policy.shouldAllowSync, isTrue);

      policy.setWifiOnlyForPrefetch(false);
      expect(policy.shouldPrefetch, isTrue);

      expect(notifications, greaterThanOrEqualTo(3));
    });
  });
}
