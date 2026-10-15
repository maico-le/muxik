import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:drift/drift.dart' show Value;
import '../data/yt/stream_resolver.dart';
import '../data/yt/yt_models.dart';
import '../data/db/app_database.dart';
import '../core/network/network_policy.dart';
import '../core/network/data_meter.dart';
import 'audio_cache_manager.dart';
import 'queue_controller.dart';

enum PlayerStatus {
  idle,
  loading,
  playing,
  paused,
  error,
}

/// Service managing AudioPlayer lifecycle, stream resolution, error handling, and state persistence
class PlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer;
  final StreamResolver _streamResolver;
  final QueueController _queueController;
  final AppDatabase _db;
  final AudioCacheManager? _cacheManager;
  final NetworkPolicy? _networkPolicy;
  final DataMeter? _dataMeter;

  PlayerStatus _status = PlayerStatus.idle;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _bufferedSub;
  Timer? _cellularPauseTimer;

  PlayerService({
    AudioPlayer? audioPlayer,
    required StreamResolver streamResolver,
    required QueueController queueController,
    required AppDatabase db,
    AudioCacheManager? cacheManager,
    NetworkPolicy? networkPolicy,
    DataMeter? dataMeter,
  })  : _audioPlayer = audioPlayer ?? AudioPlayer(),
        _streamResolver = streamResolver,
        _queueController = queueController,
        _db = db,
        _cacheManager = cacheManager,
        _networkPolicy = networkPolicy,
        _dataMeter = dataMeter {
    _initListeners();
    _queueController.addListener(_onQueueChanged);
  }

  // --- Getters ---
  AudioPlayer get audioPlayer => _audioPlayer;
  QueueController get queueController => _queueController;
  PlayerStatus get status => _status;
  bool get isPlaying => _status == PlayerStatus.playing;
  bool get isLoading => _status == PlayerStatus.loading;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  String? get errorMessage => _errorMessage;
  YtTrack? get currentTrack => _queueController.currentTrack;

  void _initListeners() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _status = PlayerStatus.loading;
      } else if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      } else if (state.playing) {
        _status = PlayerStatus.playing;
        _cellularPauseTimer?.cancel();
      } else {
        _status = PlayerStatus.paused;
        _handleCellularPauseTimeout();
      }
      notifyListeners();
    });

    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _bufferedSub = _audioPlayer.bufferedPositionStream.listen((buf) {
      _bufferedPosition = buf;
      notifyListeners();
    });
  }

  void _handleCellularPauseTimeout() {
    _cellularPauseTimer?.cancel();
    if (_networkPolicy?.isCellular == true) {
      // Spec 7.4: Dừng tải khi pause quá 60s trên di động
      _cellularPauseTimer = Timer(const Duration(seconds: 60), () {
        if (_status == PlayerStatus.paused) {
          _audioPlayer.pause();
        }
      });
    }
  }

  void _onQueueChanged() {
    notifyListeners();
  }

  /// Play track at specific index in queue
  Future<void> playTrackAtIndex(int index) async {
    _queueController.jumpToIndex(index);
    await _resolveAndPlay();
  }

  /// Play a whole list of tracks (e.g. from playlist or search)
  Future<void> playQueue(List<YtTrack> tracks, {int startIndex = 0}) async {
    _queueController.setQueue(tracks, startIndex: startIndex);
    await _resolveAndPlay();
  }

  /// Resolve stream and start playback with data saver policy & LRU cache
  Future<void> _resolveAndPlay({Duration? startPosition}) async {
    final track = currentTrack;
    if (track == null) {
      await _audioPlayer.stop();
      _status = PlayerStatus.idle;
      notifyListeners();
      return;
    }

    _status = PlayerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final preferLow = _networkPolicy?.shouldPreferLowBitrate ?? false;
      final resolved = await _streamResolver.resolve(
        track.videoId,
        preferLowBitrate: preferLow,
      );

      // 1. Check local audio cache (0 network bytes!)
      final cachedFile = await _cacheManager?.getCachedFile(track.videoId, resolved.itag);
      if (cachedFile != null && await cachedFile.exists()) {
        await _audioPlayer.setAudioSource(
          AudioSource.file(cachedFile.path),
          initialPosition: startPosition,
        );
      } else {
        // Stream and cache to disk
        final cachePath = await _cacheManager?.getFilePath(track.videoId, resolved.itag);
        if (cachePath != null) {
          final cacheFile = File(cachePath);
          // ignore: experimental_member_use
          final source = LockCachingAudioSource(
            Uri.parse(resolved.url),
            cacheFile: cacheFile,
          );
          await _audioPlayer.setAudioSource(source, initialPosition: startPosition);

          if (resolved.contentLength != null && resolved.contentLength! > 0) {
            _dataMeter?.recordUsage(kind: 'audio', bytes: resolved.contentLength!);
          }

          _checkAndRegisterCache(track.videoId, resolved.itag, cacheFile);
        } else {
          await _audioPlayer.setUrl(resolved.url, initialPosition: startPosition);
          if (resolved.contentLength != null && resolved.contentLength! > 0) {
            _dataMeter?.recordUsage(kind: 'audio', bytes: resolved.contentLength!);
          }
        }
      }

      await _audioPlayer.play();
      _status = PlayerStatus.playing;
      _cellularPauseTimer?.cancel();

      // Update lastPlayedAt in database
      await (_db.update(_db.tracks)..where((t) => t.videoId.equals(track.videoId))).write(
        TracksCompanion(
          lastPlayedAt: Value(DateTime.now()),
        ),
      );

      _persistQueueState();

      // Trigger conditional prefetch for next track
      _triggerConditionalPrefetch();
    } catch (e) {
      _status = PlayerStatus.error;
      _errorMessage = 'Failed to play track: $e';
      notifyListeners();

      // Per spec 5.8: Mark track unplayable and advance automatically
      _onTrackCompleted();
    }
  }

  void _checkAndRegisterCache(String videoId, int itag, File cacheFile) {
    Future.delayed(const Duration(seconds: 5), () async {
      if (await cacheFile.exists()) {
        final len = await cacheFile.length();
        if (len > 0) {
          await _cacheManager?.registerCacheEntry(videoId, itag, cacheFile.path, len);
        }
      }
    });
  }

  void _triggerConditionalPrefetch() {
    final policy = _networkPolicy;
    if (policy == null || !policy.shouldPrefetch) return;
    final nextTrack = _queueController.peekNext();
    if (nextTrack == null) return;

    unawaited(() async {
      try {
        await _streamResolver.resolve(
          nextTrack.videoId,
          preferLowBitrate: policy.shouldPreferLowBitrate,
        );
      } catch (_) {}
    }());
  }

  /// Handle track completion according to loop mode & queue
  void _onTrackCompleted() async {
    final nextTrack = _queueController.next(trackCompleted: true);
    if (nextTrack != null) {
      await _resolveAndPlay();
    } else {
      await _audioPlayer.stop();
      _status = PlayerStatus.idle;
      notifyListeners();
    }
  }

  /// Play
  Future<void> play() async {
    if (!_audioPlayer.playing) {
      if (currentTrack != null) {
        if (_audioPlayer.processingState == ProcessingState.idle) {
          await _resolveAndPlay(startPosition: _position);
        } else {
          await _audioPlayer.play();
        }
      }
    }
  }

  /// Pause
  Future<void> pause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    }
  }

  /// Play or Pause toggle
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Next track button
  Future<void> next() async {
    final nextTrack = _queueController.next(trackCompleted: false);
    if (nextTrack != null) {
      await _resolveAndPlay();
    }
  }

  /// Previous track button (spec 6.2: > 3s seeks to 0, <= 3s steps back)
  Future<void> previous() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final prevTrack = _queueController.previous();
    if (prevTrack != null) {
      await _resolveAndPlay();
    }
  }

  /// Seek to duration
  Future<void> seek(Duration target) async {
    await _audioPlayer.seek(target);
  }

  /// Persist queue state to SQLite DB
  Future<void> _persistQueueState() async {
    try {
      final trackIds = _queueController.queue.map((t) => t.videoId).toList();
      await _db.into(_db.queueState).insertOnConflictUpdate(
            QueueStateCompanion(
              id: const Value(1),
              trackIdsJson: Value(trackIds.join(',')),
              currentIndex: Value(_queueController.currentIndex),
              positionMs: Value(_position.inMilliseconds),
              shuffleOn: Value(_queueController.shuffleOn),
              loopMode: Value(_queueController.loopMode.name),
              loopCount: Value(_queueController.loopCountN),
            ),
          );
    } catch (_) {}
  }

  @override
  void dispose() {
    _cellularPauseTimer?.cancel();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();
    _queueController.removeListener(_onQueueChanged);
    _audioPlayer.dispose();
    super.dispose();
  }
}
