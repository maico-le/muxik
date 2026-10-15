import 'package:flutter_test/flutter_test.dart';
import 'package:musical/audio/queue_controller.dart';
import 'package:musical/data/yt/yt_models.dart';

void main() {
  group('QueueController Unit Tests', () {
    late List<YtTrack> tracks;

    setUp(() {
      tracks = List.generate(
        5,
        (i) => YtTrack(
          videoId: 'vid_$i',
          title: 'Track $i',
          artists: ['Artist $i'],
          durationMs: 180000,
          thumbUrl: 'https://example.com/$i.jpg',
        ),
      );
    });

    test('Initial queue setup correctly sets currentTrack and length', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 0);

      expect(qc.queue.length, equals(5));
      expect(qc.currentIndex, equals(0));
      expect(qc.currentTrack?.videoId, equals('vid_0'));
    });

    test('Sequential playback progresses forward until end in LoopMode.off', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 0);

      final t1 = qc.next();
      expect(t1?.videoId, equals('vid_1'));
      expect(qc.currentIndex, equals(1));

      final t2 = qc.next();
      expect(t2?.videoId, equals('vid_2'));

      qc.jumpToIndex(4);
      final tEnd = qc.next();
      expect(tEnd, isNull); // End of queue in loopMode.off
    });

    test('LoopMode.all wraps around to beginning upon reaching queue end', () {
      final qc = QueueController(
        initialQueue: tracks,
        initialIndex: 4,
        loopMode: LoopMode.all,
      );

      final nextTrack = qc.next();
      expect(nextTrack?.videoId, equals('vid_0'));
      expect(qc.currentIndex, equals(0));
    });

    test('LoopMode.one repeats current song when track completes', () {
      final qc = QueueController(
        initialQueue: tracks,
        initialIndex: 2,
        loopMode: LoopMode.one,
      );

      final nextTrack = qc.next(trackCompleted: true);
      expect(nextTrack?.videoId, equals('vid_2'));
      expect(qc.currentIndex, equals(2));
    });

    test('LoopMode.oneTimesN repeats track exactly N times then proceeds to next', () {
      final qc = QueueController(
        initialQueue: tracks,
        initialIndex: 0,
        loopMode: LoopMode.oneTimesN,
        loopCountN: 3,
      );

      // Repeat 1
      final r1 = qc.next(trackCompleted: true);
      expect(r1?.videoId, equals('vid_0'));
      expect(qc.currentNRepeats, equals(1));

      // Repeat 2
      final r2 = qc.next(trackCompleted: true);
      expect(r2?.videoId, equals('vid_0'));
      expect(qc.currentNRepeats, equals(2));

      // Repeat 3 reaches N=3 -> advances to vid_1
      final r3 = qc.next(trackCompleted: true);
      expect(r3?.videoId, equals('vid_1'));
      expect(qc.currentNRepeats, equals(0));
    });

    test('Shuffle Bag plays every track once without repeating before refreshing', () {
      final qc = QueueController(
        initialQueue: tracks,
        initialIndex: 0,
        shuffleOn: true,
      );

      final playedIds = <String>{qc.currentTrack!.videoId};

      for (var i = 1; i < tracks.length; i++) {
        final t = qc.next();
        expect(t, isNotNull);
        expect(playedIds.contains(t!.videoId), isFalse,
            reason: 'Track should not repeat in the same shuffle cycle');
        playedIds.add(t.videoId);
      }

      expect(playedIds.length, equals(5));
      // End of shuffle bag
      expect(qc.next(), isNull);
    });

    test('Previous steps backwards through history accurately', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 0);

      qc.jumpToIndex(3);
      qc.jumpToIndex(1);

      // History should step back: 1 -> 3 -> 0
      final p1 = qc.previous();
      expect(p1?.videoId, equals('vid_3'));

      final p2 = qc.previous();
      expect(p2?.videoId, equals('vid_0'));
    });

    test('playNext inserts track directly after current index', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 1);
      const newTrack = YtTrack(
        videoId: 'new_vid',
        title: 'New Track',
        artists: ['Special'],
        durationMs: 120000,
        thumbUrl: '',
      );

      qc.playNext(newTrack);
      expect(qc.queue[2].videoId, equals('new_vid'));
      expect(qc.queue.length, equals(6));
    });

    test('addToEnd appends track to queue end', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 1);
      const newTrack = YtTrack(
        videoId: 'last_vid',
        title: 'Last Track',
        artists: ['Special'],
        durationMs: 120000,
        thumbUrl: '',
      );

      qc.addToEnd(newTrack);
      expect(qc.queue.last.videoId, equals('last_vid'));
      expect(qc.queue.length, equals(6));
    });

    test('reorder updates queue order and currentIndex pointer safely', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 0);

      // Move index 0 to index 3
      qc.reorder(0, 3);
      expect(qc.queue[2].videoId, equals('vid_0'));
      expect(qc.currentIndex, equals(2));
    });

    test('removeAt removes track and adjusts currentIndex pointer safely', () {
      final qc = QueueController(initialQueue: tracks, initialIndex: 2);

      // Remove element before current
      qc.removeAt(0);
      expect(qc.currentIndex, equals(1));
      expect(qc.queue.length, equals(4));

      // Remove current element
      qc.removeAt(1);
      expect(qc.currentIndex, equals(1));
      expect(qc.currentTrack?.videoId, equals('vid_3'));
    });
  });
}
