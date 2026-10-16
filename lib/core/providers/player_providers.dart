import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../audio/queue_controller.dart';
import '../../audio/player_service.dart';
import '../../audio/audio_handler.dart';
import '../../data/yt/stream_resolver.dart';
import 'auth_providers.dart';

import 'network_providers.dart';

export '../../audio/player_service.dart' show PlayerService, PlayerStatus;
export '../../audio/queue_controller.dart' show QueueController, LoopMode;

/// StreamResolver Provider
final streamResolverProvider = Provider<StreamResolver>((ref) {
  final ytClient = ref.watch(ytClientProvider);
  return StreamResolver(ytClient: ytClient);
});

/// QueueController Provider
final queueControllerProvider = ChangeNotifierProvider<QueueController>((ref) {
  return QueueController();
});

/// PlayerService Provider
final playerServiceProvider = ChangeNotifierProvider<PlayerService>((ref) {
  final streamResolver = ref.watch(streamResolverProvider);
  final queueController = ref.watch(queueControllerProvider);
  final db = ref.watch(appDatabaseProvider);
  final cacheManager = ref.read(audioCacheManagerProvider);
  final networkPolicy = ref.read(networkPolicyProvider);
  final dataMeter = ref.read(dataMeterProvider);

  final audioPlayer = AudioPlayer(
    userAgent:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  );

  final player = PlayerService(
    audioPlayer: audioPlayer,
    streamResolver: streamResolver,
    queueController: queueController,
    db: db,
    cacheManager: cacheManager,
    networkPolicy: networkPolicy,
    dataMeter: dataMeter,
  );

  return player;
});

/// MusicalAudioHandler Provider for AudioService foreground management
final audioHandlerProvider = Provider<MusicalAudioHandler>((ref) {
  final playerService = ref.read(playerServiceProvider);
  final queueController = ref.read(queueControllerProvider);

  return MusicalAudioHandler(
    playerService: playerService,
    queueController: queueController,
  );
});
