import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'queue_controller.dart';
import 'player_service.dart';

/// AudioHandler background service implementation supporting notification, lock screen, audio focus and headphone events
class MusicalAudioHandler extends BaseAudioHandler with SeekHandler {
  final PlayerService playerService;
  final QueueController queueController;
  AudioSession? _session;

  MusicalAudioHandler({
    required this.playerService,
    required this.queueController,
  }) {
    _initAudioSession();
    _listenToPlayerChanges();
    _updatePlaybackState();
    _updateMediaItem();
  }

  Future<void> _initAudioSession() async {
    try {
      _session = await AudioSession.instance;
      await _session?.configure(const AudioSessionConfiguration.music());

      // Handle audio interruptions (e.g. phone call, alarm, other media apps)
      _session?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              playerService.audioPlayer.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              playerService.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              playerService.audioPlayer.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              playerService.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Handle unplugging headphones / becoming noisy
      _session?.becomingNoisyEventStream.listen((_) {
        playerService.pause();
      });
    } catch (_) {
      // AudioSession plugin unavailable in mock / test / desktop runtimes
    }
  }

  void _listenToPlayerChanges() {
    // 1. Sync PlaybackState with lock screen controls
    playerService.addListener(_updatePlaybackState);

    // 2. Sync MediaItem with active track
    queueController.addListener(_updateMediaItem);
  }

  void _updateMediaItem() {
    final track = queueController.currentTrack;
    if (track == null) {
      mediaItem.add(null);
      return;
    }

    final item = MediaItem(
      id: track.videoId,
      album: track.album ?? 'YouTube Music',
      title: track.title,
      artist: track.artistsDisplay,
      duration: Duration(milliseconds: track.durationMs),
      artUri: track.thumbUrl.isNotEmpty ? Uri.tryParse(track.thumbUrl) : null,
      extras: {
        'setVideoId': track.setVideoId,
      },
    );

    mediaItem.add(item);
  }

  void _updatePlaybackState() {
    final isPlaying = playerService.isPlaying;
    final isLoading = playerService.isLoading;

    final controls = [
      MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: isLoading
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: playerService.position,
        bufferedPosition: playerService.bufferedPosition,
        speed: 1.0,
        queueIndex: queueController.currentIndex,
        shuffleMode: queueController.shuffleOn
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: _toAudioServiceRepeatMode(queueController.loopMode),
      ),
    );
  }

  AudioServiceRepeatMode _toAudioServiceRepeatMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
      case LoopMode.oneTimesN:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  // --- AudioHandler overrides triggered by lock screen, notification, or headset ---

  @override
  Future<void> play() => playerService.play();

  @override
  Future<void> pause() => playerService.pause();

  @override
  Future<void> stop() async {
    await playerService.audioPlayer.stop();
    await playbackState.firstWhere((state) => !state.playing);
  }

  @override
  Future<void> skipToNext() => playerService.next();

  @override
  Future<void> skipToPrevious() => playerService.previous();

  @override
  Future<void> seek(Duration position) => playerService.seek(position);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    queueController.toggleShuffle();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    queueController.cycleLoopMode();
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'cycleLoop':
        queueController.cycleLoopMode();
        break;
      case 'toggleShuffle':
        queueController.toggleShuffle();
        break;
    }
  }
}
