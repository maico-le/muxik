import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/yt/yt_models.dart';
import 'package:musical/data/yt/innertube_parser.dart';
import 'package:musical/data/repo/search_repo.dart';

class MockYtClient extends Mock implements YtClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('SearchRepo Unit Tests', () {
    late AppDatabase db;
    late MockYtClient mockYtClient;
    late SearchRepo searchRepo;

    final fixtureJson = File('test/fixtures/search_results.json').readAsStringSync();
    final fixturePage = InnerTubeParser.parseSearchResults(fixtureJson);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockYtClient = MockYtClient();
      searchRepo = SearchRepo(ytClient: mockYtClient, db: db);

      registerFallbackValue(SearchFilter.all);
    });

    tearDown(() async {
      await db.close();
    });

    test('search invokes YtClient and records query to SQLite search_history', () async {
      when(() => mockYtClient.search(
            any(),
            filter: any(named: 'filter'),
            continuation: any(named: 'continuation'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => fixturePage);

      final result = await searchRepo.search('Rick Astley', filter: SearchFilter.songs);

      expect(result.items.length, equals(3));
      verify(() => mockYtClient.search(
            'Rick Astley',
            filter: SearchFilter.songs,
            continuation: null,
            cancelToken: any(named: 'cancelToken'),
          )).called(1);

      // Verify recorded in SQLite history
      final history = await searchRepo.getHistory();
      expect(history.length, equals(1));
      expect(history.first.query, equals('Rick Astley'));
    });

    test('search utilizes 5-minute memory cache to avoid redundant network calls', () async {
      when(() => mockYtClient.search(
            any(),
            filter: any(named: 'filter'),
            continuation: any(named: 'continuation'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => fixturePage);

      // First call -> queries network
      await searchRepo.search('Pixel Music');
      // Second identical call -> should hit 5-minute cache
      await searchRepo.search('Pixel Music');

      verify(() => mockYtClient.search(
            'Pixel Music',
            filter: any(named: 'filter'),
            continuation: any(named: 'continuation'),
            cancelToken: any(named: 'cancelToken'),
          )).called(1); // Called only once!
    });

    test('SQLite search history supports watch, remove and clear operations', () async {
      await searchRepo.addHistory('Query A');
      await searchRepo.addHistory('Query B');
      await searchRepo.addHistory('Query C');

      var list = await searchRepo.getHistory();
      expect(list.length, equals(3));

      // Remove single query
      await searchRepo.removeHistory('Query B');
      list = await searchRepo.getHistory();
      expect(list.length, equals(2));
      expect(list.any((h) => h.query == 'Query B'), isFalse);

      // Clear all
      await searchRepo.clearHistory();
      list = await searchRepo.getHistory();
      expect(list, isEmpty);
    });
  });
}
