import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/core/network/network_policy.dart';
import 'package:musical/core/network/data_meter.dart';
import 'package:musical/core/network/data_meter_interceptor.dart';
import 'package:dio/dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Milestone 8 - DataMeter & Byte Tracking Tests', () {
    late AppDatabase db;
    late NetworkPolicy networkPolicy;
    late DataMeter dataMeter;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      networkPolicy = NetworkPolicy(initialNetwork: NetworkType.cellular, autoListen: false);
      dataMeter = DataMeter(db: db, networkPolicy: networkPolicy);
    });

    tearDown(() async {
      await db.close();
    });

    test('Records byte transfers and aggregates entries for same day', () async {
      final today = DateTime.now();

      await dataMeter.recordUsage(kind: 'audio', bytes: 1000, network: 'cell');
      await dataMeter.recordUsage(kind: 'audio', bytes: 2500, network: 'cell');
      await dataMeter.recordUsage(kind: 'image', bytes: 500, network: 'cell');
      await dataMeter.recordUsage(kind: 'api', bytes: 200, network: 'wifi');

      final cellAudio = await dataMeter.getDayUsage(today, network: 'cell', kind: 'audio');
      expect(cellAudio, equals(3500));

      final cellImage = await dataMeter.getDayUsage(today, network: 'cell', kind: 'image');
      expect(cellImage, equals(500));

      final wifiApi = await dataMeter.getDayUsage(today, network: 'wifi', kind: 'api');
      expect(wifiApi, equals(200));

      final totalCell = await dataMeter.getDayUsage(today, network: 'cell');
      expect(totalCell, equals(4000));
    });

    test('Cellular byte recording updates NetworkPolicy monthly cellular counter', () async {
      await dataMeter.recordUsage(kind: 'audio', bytes: 5000, network: 'cell');
      expect(networkPolicy.currentMonthCellularBytes, equals(5000));

      await dataMeter.recordUsage(kind: 'audio', bytes: 15000, network: 'cell');
      expect(networkPolicy.currentMonthCellularBytes, equals(20000));

      // Wi-Fi usage does NOT increase cellular meter
      await dataMeter.recordUsage(kind: 'audio', bytes: 100000, network: 'wifi');
      expect(networkPolicy.currentMonthCellularBytes, equals(20000));
    });

    test('getDailyHistory produces accurate multi-day summaries', () async {
      await dataMeter.recordUsage(kind: 'audio', bytes: 12000, network: 'cell');
      await dataMeter.recordUsage(kind: 'image', bytes: 3000, network: 'wifi');

      final history = await dataMeter.getDailyHistory(days: 7);
      expect(history.length, equals(7));

      final todaySummary = history.last;
      expect(todaySummary.cellBytes, equals(12000));
      expect(todaySummary.wifiBytes, equals(3000));
      expect(todaySummary.audioBytes, equals(12000));
      expect(todaySummary.imageBytes, equals(3000));
      expect(todaySummary.totalBytes, equals(15000));
    });

    test('DataMeterInterceptor measures Dio HTTP requests and responses', () async {
      final interceptor = DataMeterInterceptor(dataMeter: dataMeter);

      // Simulate Request
      final requestOptions = RequestOptions(
        path: '/test/api',
        data: '{"query":"pixel art"}',
      );
      final reqHandler = RequestInterceptorHandler();
      interceptor.onRequest(requestOptions, reqHandler);

      // Simulate Response
      final response = Response(
        requestOptions: requestOptions,
        headers: Headers.fromMap({
          Headers.contentLengthHeader: ['4096'],
        }),
      );
      final resHandler = ResponseInterceptorHandler();
      interceptor.onResponse(response, resHandler);

      // Allow async recordUsage DB operations to finish
      await Future.delayed(const Duration(milliseconds: 100));

      final apiUsage = await dataMeter.getDayUsage(DateTime.now(), kind: 'api');
      // Should include request body (~22 bytes) + 4096 response bytes
      expect(apiUsage, greaterThanOrEqualTo(4096));
    });
  });
}
