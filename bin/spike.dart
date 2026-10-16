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
    for (final client in [
      (
        'IOS',
        '21.26.4',
        '5',
        'com.google.ios.youtube/21.26.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
        {
          'clientName': 'IOS',
          'clientVersion': '21.26.4',
          'deviceMake': 'Apple',
          'deviceModel': 'iPhone16,2',
          'userAgent': 'com.google.ios.youtube/21.26.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
          'osName': 'iPhone',
          'osVersion': '18.3.2.22D82',
          'hl': 'en',
          'gl': 'US',
        }
      ),
      (
        'ANDROID',
        '21.26.364',
        '3',
        'com.google.android.youtube/21.26.364 (Linux; U; Android 11) gzip',
        {
          'clientName': 'ANDROID',
          'clientVersion': '21.26.364',
          'androidSdkVersion': 30,
          'userAgent': 'com.google.android.youtube/21.26.364 (Linux; U; Android 11) gzip',
          'osName': 'Android',
          'osVersion': '11',
          'hl': 'en',
          'gl': 'US',
        }
      ),
    ]) {
      try {
        final body = {
          'context': {
            'client': client.$5,
          },
          'videoId': videoId,
          'contentCheckOk': true,
          'racyCheckOk': true,
        };
        final res = await dio.post<Map<String, dynamic>>(
          'https://www.youtube.com/youtubei/v1/player',
          data: body,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'User-Agent': client.$4,
            'X-YouTube-Client-Name': client.$3,
            'X-YouTube-Client-Version': client.$2,
          }),
        );
        final status = res.data?['playabilityStatus']?['status'];
        final streamingData = res.data?['streamingData'];
        final adaptive = streamingData?['adaptiveFormats'] as List<dynamic>? ?? [];
        final audio = adaptive.where((f) => (f['mimeType'] as String? ?? '').startsWith('audio/')).toList();
        final withUrl = audio.where((f) => f['url'] != null).toList();
        stdout.writeln('  [${client.$1}] Status: $status, Audio formats: ${audio.length}, Direct URLs: ${withUrl.length}');
        if (audio.isNotEmpty) {
          stdout.writeln('    -> Keys: ${audio.first.keys.toList()}');
          if (audio.first['signatureCipher'] != null) {
            stdout.writeln('    -> signatureCipher: ${audio.first['signatureCipher']?.substring(0, 50)}...');
          }
          if (audio.first['cipher'] != null) {
            stdout.writeln('    -> cipher: ${audio.first['cipher']?.substring(0, 50)}...');
          }
        }
        if (withUrl.isNotEmpty) {
          stdout.writeln('    -> itag: ${withUrl.first['itag']}, URL: ${withUrl.first['url']?.substring(0, 60)}...');
        }
      } catch (e) {
        stdout.writeln('  [${client.$1}] Error: $e');
      }
    }
    try {
      // Cellular mode (prefer <= 64kbps opus / itag 249)
      final cellularStream = await streamResolver.resolve(
        videoId,
        preferLowBitrate: true,
      );
      stdout.writeln('  [Cellular] Format: itag=${cellularStream.itag}, mime=${cellularStream.mimeType}, bitrate=${cellularStream.bitrate}');
      stdout.writeln('  [Cellular] URL: ${cellularStream.url.substring(0, cellularStream.url.indexOf('?'))}?...');

      // Test 3: HTTP Range Byte Verification (verifying actual playability & connectivity)
      stdout.writeln('  [Verify] Testing HTTP Range request with Referer and Origin...');
      try {
        final r1 = await dio.get<List<int>>(
          cellularStream.url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Range': 'bytes=0-1023',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
              'Referer': 'https://music.youtube.com/',
              'Origin': 'https://music.youtube.com',
            },
          ),
        );
        stdout.writeln('  [Verify] With Referer/Origin Status: ${r1.statusCode}');
      } catch (e) {
        stdout.writeln('  [Verify] With Referer/Origin FAILED: $e');
      }

      stdout.writeln('  [Verify] Testing HTTP Range request with ONLY User-Agent...');
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
      stdout.writeln('  [Verify] Only User-Agent Status: ${headResponse.statusCode}');

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
