import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:musical/data/yt/innertube_parser.dart';

void main() {
  group('InnerTubeParser Fixture Tests', () {
    test('parseLibraryPlaylists extracts playlists correctly from JSON fixture', () {
      final jsonStr = File('test/fixtures/library_playlists.json').readAsStringSync();
      final page = InnerTubeParser.parseLibraryPlaylists(jsonStr);

      expect(page.items, isNotEmpty);
      expect(page.items.length, equals(2));

      final first = page.items.first;
      expect(first.id, equals('PLretro_pixel_chiptune_01'));
      expect(first.title, equals('Pixel Chiptune Hits'));
      expect(first.thumbUrl, contains('sample_playlist_thumb_1.jpg'));
      expect(first.trackCount, equals(42));

      final second = page.items[1];
      expect(second.id, equals('PLlofi_8bit_beats_02'));
      expect(second.title, equals('Lo-Fi 8-Bit Beats'));
      expect(second.trackCount, equals(15));
    });

    test('parsePlaylistTracks extracts tracks correctly from JSON fixture', () {
      final jsonStr = File('test/fixtures/playlist_tracks.json').readAsStringSync();
      final page = InnerTubeParser.parsePlaylistTracks(jsonStr);

      expect(page.items, isNotEmpty);
      expect(page.items.length, equals(2));

      final first = page.items.first;
      expect(first.videoId, equals('dQw4w9WgXcQ'));
      expect(first.title, equals('Never Gonna Give You Up'));
      expect(first.artists, contains('Rick Astley'));
      expect(first.album, equals('Whenever You Need Somebody'));
      expect(first.durationMs, equals(212000));
      expect(first.setVideoId, equals('SET_VIDEO_ID_001'));

      final second = page.items[1];
      expect(second.videoId, equals('9bZkp7q19f0'));
      expect(second.title, equals('Gangnam Style'));
      expect(second.artists, contains('PSY'));
      expect(second.durationMs, equals(252000));
    });

    test('parseLibraryPlaylists handles empty or malformed JSON gracefully without crashing', () {
      final pageEmpty = InnerTubeParser.parseLibraryPlaylists({});
      expect(pageEmpty.items, isEmpty);
      expect(pageEmpty.hasMore, isFalse);

      final pageRandom = InnerTubeParser.parseLibraryPlaylists({
        'contents': {'unexpectedKey': 123}
      });
      expect(pageRandom.items, isEmpty);
    });

    test('parsePlaylistTracks handles empty or malformed JSON gracefully without crashing', () {
      final pageEmpty = InnerTubeParser.parsePlaylistTracks({});
      expect(pageEmpty.items, isEmpty);
      expect(pageEmpty.hasMore, isFalse);
    });
  });
}
