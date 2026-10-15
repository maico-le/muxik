import 'dart:convert';
import 'dart:io';
import 'yt_models.dart';

/// Fake repository reading from local fixtures for dev mode, offline tests, and screenshots
class FakeYtRepository {
  final String fixturesPath;

  FakeYtRepository({this.fixturesPath = 'test/fixtures'});

  Future<String> _readFixture(String name) async {
    // Read from file system directly
    final file = File('$fixturesPath/$name');
    if (await file.exists()) {
      return await file.readAsString();
    }
    // Check fallback in root test/fixtures or assets
    final altFile = File('test/fixtures/$name');
    if (await altFile.exists()) {
      return await altFile.readAsString();
    }
    throw Exception('Fixture $name not found in $fixturesPath');
  }

  Future<List<YtAccount>> getAccountSwitcher() async {
    var raw = await _readFixture('account_switcher.json');
    if (raw.startsWith(")]}'\n")) {
      raw = raw.substring(5);
    } else if (raw.startsWith(")]}'")) {
      raw = raw.substring(4);
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final accounts = <YtAccount>[];

    void findAccountItems(dynamic node) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('accountItemRenderer')) {
          final item = node['accountItemRenderer'] as Map<String, dynamic>;
          final runs = item['accountName']?['runs'] as List<dynamic>?;
          final name = runs != null && runs.isNotEmpty ? runs[0]['text']?.toString() ?? 'Pixel User' : 'Pixel User';
          final emailRuns = item['accountEmail']?['runs'] as List<dynamic>?;
          final email = emailRuns != null && emailRuns.isNotEmpty ? emailRuns[0]['text']?.toString() ?? '' : '';
          final thumbs = item['accountPhoto']?['thumbnails'] as List<dynamic>?;
          final thumb = thumbs != null && thumbs.isNotEmpty ? thumbs[0]['url']?.toString() ?? '' : '';
          final isSelected = item['isSelected'] == true;
          final endpoint = item['serviceEndpoint'] ?? item['navigationEndpoint'];
          final pageId = endpoint?['selectActiveIdentityEndpoint']?['supportedTokens']?[0]?['pageId'] as String?;

          accounts.add(
            YtAccount(
              email: email.isNotEmpty ? email : name,
              name: name,
              thumbUrl: thumb,
              pageId: pageId,
              authUser: 0,
              isUsed: isSelected,
            ),
          );
        } else {
          for (final val in node.values) {
            findAccountItems(val);
          }
        }
      } else if (node is List) {
        for (final elem in node) {
          findAccountItems(elem);
        }
      }
    }

    findAccountItems(json);
    return accounts;
  }

  Future<List<YtPlaylist>> getLibraryPlaylists() async {
    final raw = await _readFixture('library_playlists.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final playlists = <YtPlaylist>[];

    void searchGridItems(dynamic node) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('musicTwoRowItemRenderer')) {
          final item = node['musicTwoRowItemRenderer'] as Map<String, dynamic>;
          final runs = item['title']?['runs'] as List<dynamic>?;
          final title = runs != null && runs.isNotEmpty ? runs[0]['text']?.toString() ?? '' : '';
          final navEndpoint = item['navigationEndpoint']?['browseEndpoint'];
          var browseId = navEndpoint?['browseId'] as String? ?? '';
          if (browseId.startsWith('VL')) {
            browseId = browseId.substring(2);
          }
          final thumbs = item['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List<dynamic>?;
          final thumb = thumbs != null && thumbs.isNotEmpty ? thumbs.last['url']?.toString() ?? '' : '';
          final subtitleRuns = item['subtitle']?['runs'] as List<dynamic>?;
          final subtitle = subtitleRuns != null && subtitleRuns.isNotEmpty ? subtitleRuns[0]['text']?.toString() ?? '' : '';
          final countMatch = RegExp(r'(\d+)').firstMatch(subtitle);
          final trackCount = countMatch != null ? int.tryParse(countMatch.group(1)!) ?? 0 : 0;

          if (browseId.isNotEmpty) {
            playlists.add(
              YtPlaylist(
                id: browseId,
                title: title.isNotEmpty ? title : 'Untitled Playlist',
                thumbUrl: thumb,
                trackCount: trackCount,
              ),
            );
          }
        } else {
          for (final val in node.values) {
            searchGridItems(val);
          }
        }
      } else if (node is List) {
        for (final elem in node) {
          searchGridItems(elem);
        }
      }
    }

    searchGridItems(data);
    return playlists;
  }

  Future<List<YtTrack>> getPlaylistTracks(String playlistId) async {
    final raw = await _readFixture('playlist_tracks.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final tracks = <YtTrack>[];

    void searchListItems(dynamic node) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('musicResponsiveListItemRenderer')) {
          final item = node['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
          final videoId = item['playlistItemData']?['videoId'] as String?;
          final flexCols = item['flexColumns'] as List<dynamic>? ?? [];

          String title = 'Unknown Title';
          final artists = <String>[];
          String? album;
          int durationMs = 0;

          if (flexCols.isNotEmpty) {
            final col0Runs = flexCols[0]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List<dynamic>?;
            if (col0Runs != null && col0Runs.isNotEmpty) {
              title = col0Runs.map((r) => r['text']?.toString() ?? '').join();
            }
          }
          if (flexCols.length > 1) {
            final col1Runs = flexCols[1]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List<dynamic>?;
            if (col1Runs != null && col1Runs.isNotEmpty) {
              artists.add(col1Runs.first['text']?.toString() ?? '');
            }
          }
          if (flexCols.length > 2) {
            final col2Runs = flexCols[2]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List<dynamic>?;
            if (col2Runs != null && col2Runs.isNotEmpty) {
              album = col2Runs.map((r) => r['text']?.toString() ?? '').join();
            }
          }
          if (flexCols.length > 3) {
            final col3Runs = flexCols[3]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List<dynamic>?;
            final timeStr = col3Runs != null && col3Runs.isNotEmpty ? col3Runs[0]['text']?.toString() : null;
            if (timeStr != null && timeStr.contains(':')) {
              final parts = timeStr.trim().split(':').map(int.parse).toList();
              if (parts.length == 2) {
                durationMs = (parts[0] * 60 + parts[1]) * 1000;
              } else if (parts.length == 3) {
                durationMs = (parts[0] * 3600 + parts[1] * 60 + parts[2]) * 1000;
              }
            }
          }

          final thumbs = item['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List<dynamic>?;
          final thumb = thumbs != null && thumbs.isNotEmpty ? thumbs.last['url']?.toString() ?? '' : '';
          final setVideoId = item['playlistSetVideoId'] as String?;

          if (videoId != null && videoId.isNotEmpty) {
            tracks.add(
              YtTrack(
                videoId: videoId,
                title: title,
                artists: artists,
                album: album,
                durationMs: durationMs,
                thumbUrl: thumb,
                setVideoId: setVideoId,
              ),
            );
          }
        } else {
          for (final val in node.values) {
            searchListItems(val);
          }
        }
      } else if (node is List) {
        for (final elem in node) {
          searchListItems(elem);
        }
      }
    }

    searchListItems(data);
    return tracks;
  }

  Future<List<AudioStreamFormat>> getAudioStreams(String videoId) async {
    final raw = await _readFixture('player_response.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final streamingData = data['streamingData'] as Map<String, dynamic>? ?? {};
    final adaptive = streamingData['adaptiveFormats'] as List<dynamic>? ?? [];

    final formats = <AudioStreamFormat>[];
    for (final item in adaptive) {
      if (item is Map<String, dynamic>) {
        final mimeType = item['mimeType'] as String? ?? '';
        if (mimeType.startsWith('audio/')) {
          formats.add(AudioStreamFormat.fromJson(item));
        }
      }
    }
    return formats;
  }
}
