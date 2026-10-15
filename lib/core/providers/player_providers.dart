import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/queue_controller.dart';
import '../../audio/player_service.dart';
import '../../audio/audio_handler.dart';
import '../../data/yt/stream_resolver.dart';
import 'auth_providers.dart';

import 'network_providers.dart';

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
  final cacheManager = ref.watch(audioCacheManagerProvider);
  final networkPolicy = ref.watch(networkPolicyProvider);
  final dataMeter = ref.watch(dataMeterProvider);

  final player = PlayerService(
    streamResolver: streamResolver,
    queueController: queueController,
    db: db,
    cacheManager: cacheManager,
    networkPolicy: networkPolicy,
    dataMeter: dataMeter,
  );

  ref.onDispose(() => player.dispose());
  return player;
});

/// MusicalAudioHandler Provider for AudioService foreground management
final audioHandlerProvider = Provider<MusicalAudioHandler>((ref) {
  final playerService = ref.watch(playerServiceProvider);
  final queueController = ref.watch(queueControllerProvider);

  return MusicalAudioHandler(
    playerService: playerService,
    queueController: queueController,
  );
});
