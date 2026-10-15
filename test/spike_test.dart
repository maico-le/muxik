import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:musical/data/yt/stream_resolver.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/yt/fake_yt_repository.dart';

void main() {
  group('Milestone 0 - Spike: InnerTube & Stream Resolution Verification', () {
    test('Fake Repository parses all JSON fixtures accurately', () async {
      final fakeRepo = FakeYtRepository(fixturesPath: 'test/fixtures');

      // 1. Account Switcher
      final accounts = await fakeRepo.getAccountSwitcher();
      expect(accounts, isNotEmpty);
      expect(accounts.first.name, equals('Pixel User'));
      expect(accounts.first.email, equals('pixel.user@example.com'));
      expect(accounts.first.pageId, equals('100023456789012345678'));

      // 2. Playlists
      final playlists = await fakeRepo.getLibraryPlaylists();
      expect(playlists, isNotEmpty);
      expect(playlists.first.id, equals('PLretro_pixel_chiptune_01'));
      expect(playlists.first.title, equals('Pixel Chiptune Hits'));
      expect(playlists.first.trackCount, equals(42));

      // 3. Tracks
      final tracks = await fakeRepo.getPlaylistTracks(playlists.first.id);
      expect(tracks.length, equals(2));
      expect(tracks.first.videoId, equals('dQw4w9WgXcQ'));
      expect(tracks.first.title, equals('Never Gonna Give You Up'));
      expect(tracks.first.artists, contains('Rick Astley'));
      expect(tracks.first.durationMs, equals(212000));

      // 4. Player Streams
      final streams = await fakeRepo.getAudioStreams(tracks.first.videoId);
      expect(streams, isNotEmpty);
      expect(streams.any((s) => s.itag == 249), isTrue);
    });

    test('Live InnerTube Stream Resolution & HTTP Range Playability Check', () async {
      final ytClient = YtClient();
      final streamResolver = StreamResolver(ytClient: ytClient);
      final dio = Dio();

      final sampleVideoIds = [
        'dQw4w9WgXcQ', // Never Gonna Give You Up
        '9bZkp7q19f0', // PSY - Gangnam Style
        'kJQP7kiw5Fk', // Luis Fonsi - Despacito
      ];

      for (final videoId in sampleVideoIds) {
        // Resolve stream for cellular data (prefer <= 64kbps opus / itag 249)
        final cellularStream = await streamResolver.resolve(
          videoId,
          preferLowBitrate: true,
        );

        expect(cellularStream.url, isNotEmpty);
        expect(cellularStream.url.startsWith('http'), isTrue);
        expect(cellularStream.itag, isNotNull);

        // Verify audio playability with HTTP Range request (fetching first 1024 bytes)
        final response = await dio.get<List<int>>(
          cellularStream.url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Range': 'bytes=0-1023',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
            },
          ),
        );

        // Google Video streaming servers return 206 Partial Content or 200 OK
        expect([200, 206], contains(response.statusCode));
        expect(response.data?.isNotEmpty, isTrue);

        // Also test Wi-Fi stream resolution
        final wifiStream = await streamResolver.resolve(
          videoId,
          preferLowBitrate: false,
        );
        expect(wifiStream.url, isNotEmpty);
        expect(wifiStream.bitrate, greaterThan(0));
      }
    }, timeout: const Timeout(Duration(seconds: 45)));
  });
}
