import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart' hide LoopMode;
import 'package:audio_service/audio_service.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/stream_resolver.dart';
import 'package:musical/data/yt/yt_models.dart';
import 'package:musical/audio/queue_controller.dart';
import 'package:musical/audio/player_service.dart';
import 'package:musical/audio/audio_handler.dart';

class MockStreamResolver extends Mock implements StreamResolver {}
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('MusicalAudioHandler Unit Tests', () {
    late AppDatabase db;
    late MockStreamResolver mockStreamResolver;
    late MockAudioPlayer mockAudioPlayer;
    late QueueController queueController;
    late PlayerService playerService;
    late MusicalAudioHandler audioHandler;

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
        artists: ['Artist B', 'Artist C'],
        durationMs: 180000,
        thumbUrl: 'https://example.com/art2.jpg',
        album: 'Album Two',
      ),
    ];

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockStreamResolver = MockStreamResolver();
      mockAudioPlayer = MockAudioPlayer();

      when(() => mockAudioPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.bufferedPositionStream).thenAnswer((_) => const Stream.empty());
      when(() => mockAudioPlayer.playing).thenReturn(false);
      when(() => mockAudioPlayer.processingState).thenReturn(ProcessingState.ready);
      when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

      queueController = QueueController(initialQueue: testTracks, initialIndex: 0);
      playerService = PlayerService(
        audioPlayer: mockAudioPlayer,
        streamResolver: mockStreamResolver,
        queueController: queueController,
        db: db,
      );

      audioHandler = MusicalAudioHandler(
        playerService: playerService,
        queueController: queueController,
      );
    });

    tearDown(() async {
      playerService.dispose();
      await db.close();
    });

    test('Initial mediaItem reflects first track in queue', () async {
      // Allow listener to fire
      queueController.notifyListeners();

      final currentItem = audioHandler.mediaItem.value;
      expect(currentItem, isNotNull);
      expect(currentItem?.id, equals('vid_1'));
      expect(currentItem?.title, equals('Song One'));
      expect(currentItem?.artist, equals('Artist A'));
      expect(currentItem?.album, equals('Album One'));
      expect(currentItem?.duration, equals(const Duration(milliseconds: 200000)));
      expect(currentItem?.artUri, equals(Uri.parse('https://example.com/art1.jpg')));
    });

    test('Queue progression updates mediaItem appropriately', () async {
      queueController.next();

      final currentItem = audioHandler.mediaItem.value;
      expect(currentItem?.id, equals('vid_2'));
      expect(currentItem?.title, equals('Song Two'));
      expect(currentItem?.artist, equals('Artist B, Artist C'));
    });

    test('AudioHandler delegates play and pause commands to PlayerService', () async {
      await audioHandler.play();
      verify(() => mockAudioPlayer.play()).called(1);

      when(() => mockAudioPlayer.playing).thenReturn(true);
      await audioHandler.pause();
      verify(() => mockAudioPlayer.pause()).called(1);
    });

    test('AudioHandler delegates seek commands', () async {
      await audioHandler.seek(const Duration(seconds: 45));
      verify(() => mockAudioPlayer.seek(const Duration(seconds: 45))).called(1);
    });

    test('AudioHandler repeatMode and shuffleMode updates reflect in playbackState', () async {
      // Toggle repeat mode
      await audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
      expect(queueController.loopMode, equals(LoopMode.one)); // cycled from off to one

      // Custom action cycleLoop
      await audioHandler.customAction('cycleLoop');
      expect(queueController.loopMode, equals(LoopMode.all)); // cycled from one to all

      // Toggle shuffle mode
      await audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
      expect(queueController.shuffleOn, isTrue);

      await audioHandler.customAction('toggleShuffle');
      expect(queueController.shuffleOn, isFalse);
    });
  });
}
