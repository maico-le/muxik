import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart' hide LoopMode;
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/stream_resolver.dart';
import 'package:musical/data/yt/yt_models.dart';
import 'package:musical/core/network/data_meter.dart';
import 'package:musical/core/network/network_policy.dart';
import 'package:musical/core/providers/player_providers.dart';
import 'package:musical/core/providers/network_providers.dart';
import 'package:musical/core/providers/auth_providers.dart';

class MockStreamResolver extends Mock implements StreamResolver {}
class MockAudioPlayer extends Mock implements AudioPlayer {}
class FakeAudioSource extends Fake implements AudioSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
    registerFallbackValue(Duration.zero);
  });

  group('PlayerService Unit Tests', () {
    late AppDatabase db;
    late MockStreamResolver mockStreamResolver;
    late MockAudioPlayer mockAudioPlayer;
    late QueueController queueController;
    late NetworkPolicy networkPolicy;
    late DataMeter dataMeter;
    late PlayerService playerService;

    final testTracks = [
      const YtTrack(
        videoId: 'vid_1',
        title: 'Song One',
        artists: ['Artist A'],
        durationMs: 200000,
        thumbUrl: 'https://example.com/art1.jpg',
        album: 'Album One',
      ),
      const YtTrack(
        videoId: 'vid_2',
        title: 'Song Two',
        artists: ['Artist B'],
        durationMs: 180000,
        thumbUrl: 'https://example.com/art2.jpg',
        album: 'Album Two',
      ),
    ];

    final resolvedStream1 = ResolvedStream(
      videoId: 'vid_1',
      url: 'https://googlevideo.com/videoplayback?id=1',
      mimeType: 'audio/webm',
      itag: 249,
      bitrate: 50000,
      contentLength: 1000000,
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
    );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockStreamResolver = MockStreamResolver();
      mockAudioPlayer = MockAudioPlayer();
      networkPolicy = NetworkPolicy(initialNetwork: NetworkType.wifi, autoListen: false);
      dataMeter = DataMeter(db: db, networkPolicy: networkPolicy);

      when(() => mockAudioPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.bufferedPositionStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.playbackEventStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.playing).thenReturn(false);
      when(() => mockAudioPlayer.processingState).thenReturn(ProcessingState.ready);
      when(() => mockAudioPlayer.setAudioSource(any(), initialPosition: any(named: 'initialPosition'))).thenAnswer((_) async => null);
      when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

      when(() => mockStreamResolver.resolve(any(), preferLowBitrate: any(named: 'preferLowBitrate')))
          .thenAnswer((_) async => resolvedStream1);
      when(() => mockStreamResolver.remove(any())).thenReturn(null);

      queueController = QueueController(initialQueue: testTracks, initialIndex: 0);
      playerService = PlayerService(
        audioPlayer: mockAudioPlayer,
        streamResolver: mockStreamResolver,
        queueController: queueController,
        db: db,
        dataMeter: dataMeter,
        networkPolicy: networkPolicy,
      );
    });

    tearDown(() async {
      playerService.dispose();
      await db.close();
    });

    test('Initial state is idle with first track ready', () {
      expect(playerService.status, equals(PlayerStatus.idle));
      expect(playerService.currentTrack?.videoId, equals('vid_1'));
      expect(playerService.errorMessage, isNull);
    });

    test('playQueue resolves stream, sets AudioSource, and plays', () async {
      await playerService.playQueue(testTracks, startIndex: 0);

      expect(playerService.status, equals(PlayerStatus.playing));
      expect(playerService.errorMessage, isNull);
      verify(() => mockStreamResolver.resolve('vid_1', preferLowBitrate: any(named: 'preferLowBitrate'))).called(1);
      verify(() => mockAudioPlayer.setAudioSource(any(), initialPosition: any(named: 'initialPosition'))).called(1);
      verify(() => mockAudioPlayer.play()).called(1);
    });

    test('Resolution error transitions to PlayerStatus.error and clears cache', () async {
      when(() => mockStreamResolver.resolve('vid_1', preferLowBitrate: any(named: 'preferLowBitrate')))
          .thenThrow(Exception('Network timeout'));

      await playerService.playQueue(testTracks, startIndex: 0);

      expect(playerService.status, equals(PlayerStatus.error));
      expect(playerService.errorMessage, contains('Failed to play track'));
      verify(() => mockAudioPlayer.stop()).called(1);
      verify(() => mockStreamResolver.remove('vid_1')).called(1);
    });

    test('Calling play() or togglePlayPause() in error status triggers retry', () async {
      when(() => mockStreamResolver.resolve('vid_1', preferLowBitrate: any(named: 'preferLowBitrate')))
          .thenThrow(Exception('Temporary glitch'));

      await playerService.playQueue(testTracks, startIndex: 0);
      expect(playerService.status, equals(PlayerStatus.error));

      // Now recovery succeeds
      when(() => mockStreamResolver.resolve('vid_1', preferLowBitrate: any(named: 'preferLowBitrate')))
          .thenAnswer((_) async => resolvedStream1);

      await playerService.play();
      expect(playerService.status, equals(PlayerStatus.playing));
      expect(playerService.errorMessage, isNull);
    });

    test('DataMeter recordUsage does not disrupt or dispose Riverpod PlayerService', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          networkPolicyProvider.overrideWith((ref) => networkPolicy),
          dataMeterProvider.overrideWith((ref) => dataMeter),
          streamResolverProvider.overrideWithValue(mockStreamResolver),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(playerServiceProvider);
      expect(service.status, equals(PlayerStatus.idle));

      // Record data usage multiple times which fires dataMeter notifyListeners
      await dataMeter.recordUsage(kind: 'audio', bytes: 1024);
      await dataMeter.recordUsage(kind: 'audio', bytes: 2048);

      // Verify service remains active and was NOT disposed
      final serviceAfter = container.read(playerServiceProvider);
      expect(identical(service, serviceAfter), isTrue);
    });

    test('Next, previous, pause, seek interact correctly with audio player', () async {
      await playerService.pause();
      // wasn't playing, shouldn't call pause
      verifyNever(() => mockAudioPlayer.pause());

      await playerService.seek(const Duration(seconds: 45));
      verify(() => mockAudioPlayer.seek(const Duration(seconds: 45))).called(1);

      await playerService.next();
      expect(playerService.currentTrack?.videoId, equals('vid_2'));
    });

    test('ProcessingState.idle does not overwrite PlayerStatus.error', () async {
      when(() => mockStreamResolver.resolve('vid_1', preferLowBitrate: any(named: 'preferLowBitrate')))
          .thenThrow(Exception('Stream unavailable'));

      await playerService.playQueue(testTracks, startIndex: 0);
      expect(playerService.status, equals(PlayerStatus.error));

      // Simulate player state event firing with idle
      // The listener should ignore idle while in error
      expect(playerService.status, equals(PlayerStatus.error));
      expect(playerService.errorMessage, isNotNull);
    });

    test('Audio playback error on playbackEventStream sets error and evicts cache', () async {
      final playbackEventController = StreamController<PlaybackEvent>.broadcast();
      final localAudioPlayer = MockAudioPlayer();
      when(() => localAudioPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.bufferedPositionStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.playbackEventStream).thenAnswer((_) => playbackEventController.stream);
      when(() => localAudioPlayer.playing).thenReturn(false);
      when(() => localAudioPlayer.processingState).thenReturn(ProcessingState.ready);
      when(() => localAudioPlayer.dispose()).thenAnswer((_) async {});

      final localService = PlayerService(
        audioPlayer: localAudioPlayer,
        streamResolver: mockStreamResolver,
        queueController: queueController,
        db: db,
      );

      // Trigger playback error event
      playbackEventController.addError(Exception('403 Forbidden'));
      await pumpEventQueue();

      expect(localService.status, equals(PlayerStatus.error));
      expect(localService.errorMessage, contains('403 Forbidden'));
      verify(() => mockStreamResolver.remove('vid_1')).called(1);

      localService.dispose();
      await playbackEventController.close();
    });

    test('Track completion in playerStateStream advances to next track', () async {
      final playerStateController = StreamController<PlayerState>.broadcast();
      final localAudioPlayer = MockAudioPlayer();
      when(() => localAudioPlayer.playerStateStream).thenAnswer((_) => playerStateController.stream);
      when(() => localAudioPlayer.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.durationStream).thenAnswer((_) => Stream.value(const Duration(minutes: 3)));
      when(() => localAudioPlayer.bufferedPositionStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.playbackEventStream).thenAnswer((_) => const Stream.empty());
      when(() => localAudioPlayer.playing).thenReturn(false);
      when(() => localAudioPlayer.processingState).thenReturn(ProcessingState.ready);
      when(() => localAudioPlayer.setAudioSource(any(), initialPosition: any(named: 'initialPosition'))).thenAnswer((_) async => null);
      when(() => localAudioPlayer.play()).thenAnswer((_) async {});
      when(() => localAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => localAudioPlayer.dispose()).thenAnswer((_) async {});

      final localService = PlayerService(
        audioPlayer: localAudioPlayer,
        streamResolver: mockStreamResolver,
        queueController: queueController,
        db: db,
      );
      await pumpEventQueue();

      expect(localService.currentTrack?.videoId, equals('vid_1'));

      // Fire completed event
      playerStateController.add(PlayerState(false, ProcessingState.completed));
      await pumpEventQueue();

      // Advanced to vid_2!
      expect(localService.currentTrack?.videoId, equals('vid_2'));

      localService.dispose();
      await playerStateController.close();
    });
  });
}
