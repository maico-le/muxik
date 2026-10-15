import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/yt/yt_models.dart';

enum LoopMode {
  off,
  one,
  all,
  oneTimesN,
}

/// Controller managing track queue, history, shuffle bag, and loop modes
class QueueController extends ChangeNotifier {
  List<YtTrack> _queue = [];
  int _currentIndex = -1;

  bool _shuffleOn = false;
  List<int> _shuffleBag = [];
  final List<int> _history = []; // History of played queue indices

  LoopMode _loopMode = LoopMode.off;
  int _loopCountN = 3; // N repeats for loopOneTimesN (2-10)
  int _currentNRepeats = 0; // count of current repeats for ONE_X_N

  QueueController({
    List<YtTrack>? initialQueue,
    int initialIndex = -1,
    bool shuffleOn = false,
    LoopMode loopMode = LoopMode.off,
    int loopCountN = 3,
  })  : _queue = initialQueue != null ? List.from(initialQueue) : [],
        _currentIndex = initialIndex,
        _shuffleOn = shuffleOn,
        _loopMode = loopMode,
        _loopCountN = loopCountN {
    if (_shuffleOn && _queue.isNotEmpty) {
      _initShuffleBag();
    }
  }

  // --- Getters ---
  List<YtTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get shuffleOn => _shuffleOn;
  LoopMode get loopMode => _loopMode;
  int get loopCountN => _loopCountN;
  int get currentNRepeats => _currentNRepeats;
  bool get isEmpty => _queue.isEmpty;
  bool get hasCurrent => _currentIndex >= 0 && _currentIndex < _queue.length;

  YtTrack? get currentTrack => hasCurrent ? _queue[_currentIndex] : null;

  // --- Queue Manipulation ---

  /// Set an entirely new queue (e.g. from playlist or album)
  void setQueue(List<YtTrack> newQueue, {int startIndex = 0}) {
    _queue = List.from(newQueue);
    _history.clear();
    _currentNRepeats = 0;

    if (_queue.isEmpty) {
      _currentIndex = -1;
      _shuffleBag.clear();
    } else {
      _currentIndex = startIndex.clamp(0, _queue.length - 1);
      if (_shuffleOn) {
        _initShuffleBag();
      }
    }
    notifyListeners();
  }

  /// Add track to play immediately after current track
  void playNext(YtTrack track) {
    if (_queue.isEmpty) {
      _queue.add(track);
      _currentIndex = 0;
    } else {
      final insertIndex = (_currentIndex + 1).clamp(0, _queue.length);
      _queue.insert(insertIndex, track);
      if (_shuffleOn) {
        _shuffleBag.add(insertIndex);
      }
    }
    notifyListeners();
  }

  /// Append track to the end of queue
  void addToEnd(YtTrack track) {
    _queue.add(track);
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
    if (_shuffleOn) {
      _shuffleBag.add(_queue.length - 1);
    }
    notifyListeners();
  }

  /// Remove track at specific index
  void removeAt(int index) {
    if (index < 0 || index >= _queue.length) return;

    _queue.removeAt(index);
    _shuffleBag.remove(index);

    // Adjust remaining indices in bag
    for (var i = 0; i < _shuffleBag.length; i++) {
      if (_shuffleBag[i] > index) {
        _shuffleBag[i]--;
      }
    }

    if (_queue.isEmpty) {
      _currentIndex = -1;
    } else if (index < _currentIndex) {
      _currentIndex--;
    } else if (_currentIndex >= _queue.length) {
      _currentIndex = _queue.length - 1;
    }
    notifyListeners();
  }

  /// Reorder track in queue
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex > _queue.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);

    // Update currentIndex pointer
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    if (_shuffleOn) {
      _initShuffleBag();
    }
    notifyListeners();
  }

  /// Jump directly to index
  void jumpToIndex(int index) {
    if (index < 0 || index >= _queue.length) return;
    if (_currentIndex != -1) {
      _history.add(_currentIndex);
    }
    _currentIndex = index;
    _currentNRepeats = 0;
    _shuffleBag.remove(index);
    notifyListeners();
  }

  // --- Navigation & Playback Flow ---

  /// Advances to next track based on loop mode and shuffle bag
  /// Returns the newly selected track or null if queue has ended.
  YtTrack? next({bool trackCompleted = false}) {
    if (_queue.isEmpty) return null;

    if (_currentIndex != -1) {
      _history.add(_currentIndex);
    }

    // 1. Loop Mode: ONE
    if (trackCompleted && _loopMode == LoopMode.one) {
      notifyListeners();
      return currentTrack;
    }

    // 2. Loop Mode: ONE_X_N
    if (trackCompleted && _loopMode == LoopMode.oneTimesN) {
      _currentNRepeats++;
      if (_currentNRepeats < _loopCountN) {
        notifyListeners();
        return currentTrack;
      }
      _currentNRepeats = 0; // finished repeating N times, proceed to next
    }

    // 3. Shuffle Mode with Bag
    if (_shuffleOn) {
      if (_shuffleBag.isEmpty) {
        if (_loopMode == LoopMode.all) {
          _initShuffleBag();
        } else {
          // Reached end of shuffle bag and not looping all
          return null;
        }
      }

      if (_shuffleBag.isNotEmpty) {
        final rand = Random();
        final bagIdx = rand.nextInt(_shuffleBag.length);
        _currentIndex = _shuffleBag.removeAt(bagIdx);
        _currentNRepeats = 0;
        notifyListeners();
        return currentTrack;
      }
      return null;
    }

    // 4. Sequential Navigation
    if (_currentIndex + 1 < _queue.length) {
      _currentIndex++;
      _currentNRepeats = 0;
      notifyListeners();
      return currentTrack;
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = 0;
      _currentNRepeats = 0;
      notifyListeners();
      return currentTrack;
    }

    return null; // End of queue reached in LoopMode.off
  }

  /// Moves to previous track according to the spec:
  /// If track played > 3s, the caller will seek to 0.
  /// If <= 3s, previous() is called to step back through history.
  YtTrack? previous() {
    if (_queue.isEmpty) return null;

    if (_history.isNotEmpty) {
      final prevIndex = _history.removeLast();
      if (prevIndex >= 0 && prevIndex < _queue.length) {
        _currentIndex = prevIndex;
        _currentNRepeats = 0;
        notifyListeners();
        return currentTrack;
      }
    }

    // Fallback if no history: step back sequentially
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentNRepeats = 0;
      notifyListeners();
      return currentTrack;
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = _queue.length - 1;
      _currentNRepeats = 0;
      notifyListeners();
      return currentTrack;
    }

    notifyListeners();
    return currentTrack;
  }

  /// Peek next track for prefetching without advancing queue state.
  /// Returns null when in shuffle mode (unpredictable next track per spec 7.4) or at queue end.
  YtTrack? peekNext() {
    if (_queue.isEmpty || _currentIndex == -1) return null;
    if (_loopMode == LoopMode.one) return currentTrack;
    if (_loopMode == LoopMode.oneTimesN && _currentNRepeats < _loopCountN - 1) return currentTrack;
    if (_shuffleOn) return null; // Spec 7.4: Không prefetch khi shuffle chưa biết bài kế

    if (_currentIndex + 1 < _queue.length) {
      return _queue[_currentIndex + 1];
    } else if (_loopMode == LoopMode.all && _queue.isNotEmpty) {
      return _queue[0];
    }
    return null;
  }

  // --- Shuffle Bag & Loop Modes ---

  void toggleShuffle() {
    _shuffleOn = !_shuffleOn;
    if (_shuffleOn) {
      _initShuffleBag();
    } else {
      _shuffleBag.clear();
    }
    notifyListeners();
  }

  /// Cycle through: OFF -> ONE -> ALL -> ONE_X_N -> OFF
  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.oneTimesN;
        break;
      case LoopMode.oneTimesN:
        _loopMode = LoopMode.off;
        break;
    }
    _currentNRepeats = 0;
    notifyListeners();
  }

  void setLoopCountN(int n) {
    _loopCountN = n.clamp(2, 10);
    notifyListeners();
  }

  void _initShuffleBag() {
    _shuffleBag = List.generate(_queue.length, (i) => i);
    // Don't replay current song right away if already playing
    if (_currentIndex >= 0) {
      _shuffleBag.remove(_currentIndex);
    }
    _shuffleBag.shuffle();
  }
}
