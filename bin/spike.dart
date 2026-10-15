import 'dart:io';
import 'package:dio/dio.dart';
import 'package:musical/data/yt/stream_resolver.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/yt/fake_yt_repository.dart';

void main() async {
  stdout.writeln('=== MUSICAL SPIKE: INNER TUBE & STREAM RESOLUTION ===');

  // Test 1: Fake Repository & Fixture Parsing
  stdout.writeln('\n[1/4] Testing Fake Repository with JSON Fixtures...');
  final fakeRepo = FakeYtRepository(fixturesPath: 'test/fixtures');
  
  final accounts = await fakeRepo.getAccountSwitcher();
  stdout.writeln('  -> Found ${accounts.length} account(s): ${accounts.map((a) => a.name).toList()}');
  assert(accounts.isNotEmpty && accounts.first.name == 'Pixel User', 'Account parsing failed');

  final playlists = await fakeRepo.getLibraryPlaylists();
  stdout.writeln('  -> Found ${playlists.length} playlist(s): ${playlists.map((p) => p.title).toList()}');
  assert(playlists.isNotEmpty && playlists.first.id == 'PLretro_pixel_chiptune_01', 'Playlist parsing failed');

  final tracks = await fakeRepo.getPlaylistTracks(playlists.first.id);
  stdout.writeln('  -> Found ${tracks.length} track(s): ${tracks.map((t) => "${t.title} (${t.videoId})").toList()}');
  assert(tracks.length == 2 && tracks.first.videoId == 'dQw4w9WgXcQ', 'Tracks parsing failed');

  final fixtureStreams = await fakeRepo.getAudioStreams(tracks.first.videoId);
  stdout.writeln('  -> Found ${fixtureStreams.length} audio format(s) in fixture.');
  assert(fixtureStreams.any((f) => f.itag == 249), 'Expected itag 249 in fixture');

  // Test 2: Real InnerTube Client Stream Resolution for Sample Videos
  final testVideoIds = [
    'dQw4w9WgXcQ', // Never Gonna Give You Up
    '9bZkp7q19f0', // PSY - Gangnam Style
    'kJQP7kiw5Fk', // Luis Fonsi - Despacito
  ];

  final ytClient = YtClient();
  final streamResolver = StreamResolver(ytClient: ytClient);
  final dio = Dio();

  stdout.writeln('\n[2/4] Testing StreamResolver with Live Endpoints for 3 Video IDs...');
  for (final videoId in testVideoIds) {
    stdout.writeln('\n--- Resolving Stream for Video ID: $videoId ---');
    try {
      // Cellular mode (prefer <= 64kbps opus / itag 249)
      final cellularStream = await streamResolver.resolve(
        videoId,
        preferLowBitrate: true,
      );
      stdout.writeln('  [Cellular] Format: itag=${cellularStream.itag}, mime=${cellularStream.mimeType}, bitrate=${cellularStream.bitrate}');
      stdout.writeln('  [Cellular] URL: ${cellularStream.url.substring(0, cellularStream.url.indexOf('?'))}?...');

      // Test 3: HTTP Range Byte Verification (verifying actual playability & connectivity)
      stdout.writeln('  [Verify] Testing HTTP Range request (first 1024 bytes)...');
      final headResponse = await dio.get<List<int>>(
        cellularStream.url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Range': 'bytes=0-1023',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
          },
        ),
      );
      stdout.writeln('  [Verify] HTTP Status: ${headResponse.statusCode}');
      stdout.writeln('  [Verify] Received ${headResponse.data?.length ?? 0} bytes. Playable: ${headResponse.statusCode == 206 || headResponse.statusCode == 200}');

      // Wi-Fi mode (prefer best audio quality)
      final wifiStream = await streamResolver.resolve(
        videoId,
        preferLowBitrate: false,
      );
      stdout.writeln('  [Wi-Fi] itag=${wifiStream.itag}, bitrate=${wifiStream.bitrate}');

    } catch (e, st) {
      stdout.writeln('  [Error] Failed to resolve or stream $videoId: $e\n$st');
      exitCode = 1;
      return;
    }
  }

  stdout.writeln('\n[4/4] ALL CHECKS PASSED: Spike Verification Completed Successfully! ✨');
}
