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

    test('parseSearchResults extracts song, artist, album and continuation token correctly', () {
      final jsonStr = File('test/fixtures/search_results.json').readAsStringSync();
      final page = InnerTubeParser.parseSearchResults(jsonStr);

      expect(page.items.length, equals(3));
      expect(page.continuation, equals('SEARCH_CONTINUATION_TOKEN_XYZ123'));
      expect(page.hasMore, isTrue);

      // Item 0: Song
      final song = page.items[0];
      expect(song.id, equals('dQw4w9WgXcQ'));
      expect(song.title, equals('Never Gonna Give You Up'));
      expect(song.isPlayable, isTrue);
      expect(song.artists, contains('Rick Astley'));
      expect(song.durationMs, equals(214000));
      expect(song.thumbUrl, equals('https://example.com/rick_astley_thumb.jpg'));

      // Item 1: Artist
      final artist = page.items[1];
      expect(artist.id, equals('UCuAXFkgsw1L7xaCfnd5JJOw'));
      expect(artist.title, equals('Rick Astley'));
      expect(artist.isPlayable, isFalse);

      // Item 2: Album
      final album = page.items[2];
      expect(album.id, equals('MPREb_123456789'));
      expect(album.title, equals('Pixel Chiptune Vol 1'));
      expect(album.isPlayable, isFalse);
    });
  });
}
