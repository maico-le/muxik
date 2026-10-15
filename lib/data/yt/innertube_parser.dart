import 'dart:convert';
import 'yt_models.dart';

/// Structured page result with items and continuation token
class PageResult<T> {
  final List<T> items;
  final String? continuation;
  final String? title;
  final String? subtitle;
  final String? thumbUrl;
  final int totalCount;

  const PageResult({
    required this.items,
    this.continuation,
    this.title,
    this.subtitle,
    this.thumbUrl,
    this.totalCount = 0,
  });

  bool get hasMore => continuation != null && continuation!.isNotEmpty;
}

/// Generic recursive JSON traversal & extraction utilities
class InnerTubeParser {
  /// Find first object matching [predicate] recursively
  static dynamic findFirst(dynamic node, bool Function(dynamic) predicate) {
    if (predicate(node)) return node;
    if (node is Map) {
      for (final val in node.values) {
        final res = findFirst(val, predicate);
        if (res != null) return res;
      }
    } else if (node is List) {
      for (final elem in node) {
        final res = findFirst(elem, predicate);
        if (res != null) return res;
      }
    }
    return null;
  }

  /// Collect all objects matching [predicate] recursively
  static List<dynamic> findAll(dynamic node, bool Function(dynamic) predicate) {
    final results = <dynamic>[];
    void search(dynamic current) {
      if (predicate(current)) {
        results.add(current);
      }
      if (current is Map) {
        for (final val in current.values) {
          search(val);
        }
      } else if (current is List) {
        for (final elem in current) {
          search(elem);
        }
      }
    }

    search(node);
    return results;
  }

  /// Extract text string from a YouTube 'runs' or 'simpleText' node
  static String? extractRunsText(dynamic node) {
    if (node == null) return null;
    if (node is Map<String, dynamic>) {
      final runs = node['runs'] as List<dynamic>?;
      if (runs != null && runs.isNotEmpty) {
        return runs.map((r) => r['text']?.toString() ?? '').join();
      }
      if (node.containsKey('simpleText')) {
        return node['simpleText']?.toString();
      }
    }
    return null;
  }

  /// Extract highest resolution thumbnail URL
  static String extractThumbnail(dynamic node) {
    if (node == null) return '';
    if (node is Map<String, dynamic>) {
      final thumbs = node['thumbnails'] as List<dynamic>? ??
          node['thumbnail']?['thumbnails'] as List<dynamic>? ??
          node['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
              as List<dynamic>?;
      if (thumbs != null && thumbs.isNotEmpty) {
        return thumbs.last['url']?.toString() ?? '';
      }
    }
    return '';
  }

  /// Parse continuation token from response
  static String? extractContinuationToken(dynamic json) {
    final contNode = findFirst(json, (node) {
      if (node is Map<String, dynamic>) {
        return node.containsKey('nextContinuationData') ||
            node.containsKey('continuationEndpoint');
      }
      return false;
    });

    if (contNode != null && contNode is Map<String, dynamic>) {
      return contNode['nextContinuationData']?['continuation'] as String? ??
          contNode['continuationEndpoint']?['continuationCommand']
              ?['token'] as String?;
    }
    return null;
  }

  /// Parse Library Playlists (`FEmusic_liked_playlists` / browse response)
  static PageResult<YtPlaylist> parseLibraryPlaylists(dynamic rawJson) {
    if (rawJson == null) return const PageResult(items: []);
    final Map<String, dynamic> json;
    if (rawJson is String) {
      final decoded = jsonDecode(rawJson);
      json = decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } else if (rawJson is Map) {
      json = Map<String, dynamic>.from(rawJson);
    } else {
      json = {};
    }

    final playlists = <YtPlaylist>[];
    final items = findAll(
      json,
      (node) => node is Map<String, dynamic> && node.containsKey('musicTwoRowItemRenderer'),
    );

    for (final item in items) {
      final renderer = item['musicTwoRowItemRenderer'] as Map<String, dynamic>;
      final title = extractRunsText(renderer['title']) ?? '';
      final navEndpoint = renderer['navigationEndpoint']?['browseEndpoint'];
      var browseId = navEndpoint?['browseId'] as String? ?? '';
      if (browseId.startsWith('VL')) {
        browseId = browseId.substring(2);
      }
      final thumb = extractThumbnail(renderer['thumbnailRenderer']);
      final subtitle = extractRunsText(renderer['subtitle']);
      final countMatch = RegExp(r'(\d+)').firstMatch(subtitle ?? '');
      final trackCount =
          countMatch != null ? int.tryParse(countMatch.group(1)!) ?? 0 : 0;

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
    }

    final continuation = extractContinuationToken(json);
    return PageResult(
      items: playlists,
      continuation: continuation,
      totalCount: playlists.length,
    );
  }

  /// Parse playlist tracks (`VL<playlistId>` / browse response)
  static PageResult<YtTrack> parsePlaylistTracks(dynamic rawJson) {
    if (rawJson == null) return const PageResult(items: []);
    final Map<String, dynamic> json;
    if (rawJson is String) {
      final decoded = jsonDecode(rawJson);
      json = decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } else if (rawJson is Map) {
      json = Map<String, dynamic>.from(rawJson);
    } else {
      json = {};
    }

    // Playlist header info if present
    String? playlistTitle;
    String? playlistThumb;

    final header = findFirst(
      json,
      (node) =>
          node is Map<String, dynamic> &&
          (node.containsKey('musicResponsiveHeaderRenderer') ||
              node.containsKey('musicDetailHeaderRenderer')),
    );

    if (header != null && header is Map<String, dynamic>) {
      final hRenderer = (header['musicResponsiveHeaderRenderer'] ??
          header['musicDetailHeaderRenderer']) as Map<String, dynamic>;
      playlistTitle = extractRunsText(hRenderer['title']);
      playlistThumb = extractThumbnail(hRenderer['thumbnail']);
    }

    final tracks = <YtTrack>[];
    final listItems = findAll(
      json,
      (node) =>
          node is Map<String, dynamic> &&
          node.containsKey('musicResponsiveListItemRenderer'),
    );

    for (final item in listItems) {
      final renderer =
          item['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
      final flexCols = renderer['flexColumns'] as List<dynamic>? ?? [];

      final videoId = renderer['playlistItemData']?['videoId'] as String? ??
          _extractVideoIdFromFlex(flexCols);
      final title = _extractTitleFromFlex(flexCols) ?? 'Unknown Title';
      final artists = _extractArtistsFromFlex(flexCols);
      final album = _extractAlbumFromFlex(flexCols);
      final durationMs = _extractDurationFromFlex(flexCols);
      final thumb = extractThumbnail(renderer['thumbnail']);
      final setVideoId = renderer['playlistSetVideoId'] as String?;

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
    }

    final continuation = extractContinuationToken(json);
    return PageResult(
      items: tracks,
      continuation: continuation,
      title: playlistTitle,
      thumbUrl: playlistThumb,
      totalCount: tracks.length,
    );
  }

  /// Parse search results into a paginated list of YtSearchResultItem
  static PageResult<YtSearchResultItem> parseSearchResults(dynamic json) {
    if (json is String) {
      json = jsonDecode(json);
    }
    if (json is! Map<String, dynamic>) {
      return const PageResult(items: []);
    }

    final rawItems = findAll(json, (node) {
      if (node is Map<String, dynamic>) {
        return node.containsKey('musicResponsiveListItemRenderer');
      }
      return false;
    });

    final results = <YtSearchResultItem>[];

    for (final raw in rawItems) {
      final item = raw['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
      final flexCols = item['flexColumns'] as List<dynamic>? ?? [];
      final thumb = extractThumbnail(item['thumbnail']);

      // 1. Title from flexCol 0
      final title = _extractTitleFromFlex(flexCols) ?? 'Unknown Title';

      // 2. VideoId / BrowseId & Navigation
      String? videoId = _extractVideoIdFromFlex(flexCols);
      if (videoId == null) {
        final overlay = item['overlay']?['musicItemThumbnailOverlayRenderer'];
        videoId = overlay?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint']?['videoId'] as String?;
      }

      final navEndpoint = item['navigationEndpoint'] as Map<String, dynamic>?;
      videoId ??= navEndpoint?['watchEndpoint']?['videoId'] as String?;
      final browseId = navEndpoint?['browseEndpoint']?['browseId'] as String?;

      // 3. Subtitle / artists / album / duration
      final artists = _extractArtistsFromFlex(flexCols);
      final album = _extractAlbumFromFlex(flexCols);
      final durationMs = _extractDurationFromFlex(flexCols);

      // Determine result type
      SearchResultType type;
      String id;

      if (videoId != null && videoId.isNotEmpty) {
        id = videoId;
        final subText = flexCols.length > 1
            ? (extractRunsText(flexCols[1]['musicResponsiveListItemFlexColumnRenderer']?['text']) ?? '')
            : '';
        if (subText.toLowerCase().contains('video')) {
          type = SearchResultType.video;
        } else {
          type = SearchResultType.song;
        }
      } else if (browseId != null && browseId.isNotEmpty) {
        id = browseId;
        if (browseId.startsWith('UC') || browseId.startsWith('FEmusic_library_privately_owned_artist')) {
          type = SearchResultType.artist;
        } else if (browseId.startsWith('VL') || browseId.startsWith('PL')) {
          type = SearchResultType.playlist;
        } else if (browseId.startsWith('MPREb_')) {
          type = SearchResultType.album;
        } else {
          type = SearchResultType.unknown;
        }
      } else {
        final browseIdFromFlex = _extractBrowseIdFromFlex(flexCols);
        if (browseIdFromFlex != null) {
          id = browseIdFromFlex;
          if (browseIdFromFlex.startsWith('UC')) {
            type = SearchResultType.artist;
          } else if (browseIdFromFlex.startsWith('VL') || browseIdFromFlex.startsWith('PL')) {
            type = SearchResultType.playlist;
          } else if (browseIdFromFlex.startsWith('MPREb_')) {
            type = SearchResultType.album;
          } else {
            type = SearchResultType.unknown;
          }
        } else {
          continue; // Skip if no valid identifier
        }
      }

      results.add(
        YtSearchResultItem(
          id: id,
          title: title,
          type: type,
          artists: artists,
          album: album,
          durationMs: durationMs,
          thumbUrl: thumb,
        ),
      );
    }

    final continuation = extractContinuationToken(json);
    return PageResult(
      items: results,
      continuation: continuation,
      totalCount: results.length,
    );
  }

  // --- Helpers for flex columns ---

  static String? _extractVideoIdFromFlex(List<dynamic> flexCols) {
    for (final col in flexCols) {
      final renderer = col['musicResponsiveListItemFlexColumnRenderer'];
      final runs = renderer?['text']?['runs'] as List<dynamic>?;
      if (runs != null) {
        for (final run in runs) {
          final nav = run['navigationEndpoint'];
          final id = nav?['watchEndpoint']?['videoId'];
          if (id is String && id.isNotEmpty) return id;
        }
      }
    }
    return null;
  }

  static String? _extractBrowseIdFromFlex(List<dynamic> flexCols) {
    for (final col in flexCols) {
      final renderer = col['musicResponsiveListItemFlexColumnRenderer'];
      final runs = renderer?['text']?['runs'] as List<dynamic>?;
      if (runs != null) {
        for (final run in runs) {
          final nav = run['navigationEndpoint'];
          final id = nav?['browseEndpoint']?['browseId'];
          if (id is String && id.isNotEmpty) return id;
        }
      }
    }
    return null;
  }

  static String? _extractTitleFromFlex(List<dynamic> flexCols) {
    if (flexCols.isEmpty) return null;
    final firstCol = flexCols[0]['musicResponsiveListItemFlexColumnRenderer'];
    return extractRunsText(firstCol?['text']);
  }

  static List<String> _extractArtistsFromFlex(List<dynamic> flexCols) {
    if (flexCols.length < 2) return [];
    final secondCol = flexCols[1]['musicResponsiveListItemFlexColumnRenderer'];
    final runs = secondCol?['text']?['runs'] as List<dynamic>?;
    if (runs == null) return [];
    final artists = <String>[];
    for (final run in runs) {
      final nav = run['navigationEndpoint'];
      final browseId = nav?['browseEndpoint']?['browseId'] as String?;
      if (browseId != null &&
          (browseId.startsWith('UC') ||
              browseId.startsWith('FEmusic_library_privately_owned_artist'))) {
        final text = run['text']?.toString();
        if (text != null && text.isNotEmpty) {
          artists.add(text);
        }
      }
    }
    if (artists.isEmpty && runs.isNotEmpty) {
      final text = runs.first['text']?.toString();
      if (text != null && text.isNotEmpty) artists.add(text);
    }
    return artists;
  }

  static String? _extractAlbumFromFlex(List<dynamic> flexCols) {
    if (flexCols.length < 3) return null;
    final thirdCol = flexCols[2]['musicResponsiveListItemFlexColumnRenderer'];
    return extractRunsText(thirdCol?['text']);
  }

  static int _extractDurationFromFlex(List<dynamic> flexCols) {
    for (final col in flexCols) {
      final renderer = col['musicResponsiveListItemFlexColumnRenderer'];
      final runs = renderer?['text']?['runs'] as List<dynamic>?;
      if (runs != null) {
        for (final run in runs) {
          final text = run['text']?.toString().trim();
          if (text != null && RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(text)) {
            final parts = text.split(':').map(int.parse).toList();
            if (parts.length == 2) {
              return (parts[0] * 60 + parts[1]) * 1000;
            } else if (parts.length == 3) {
              return (parts[0] * 3600 + parts[1] * 60 + parts[2]) * 1000;
            }
          }
        }
      }
      final simpleText = renderer?['text']?['simpleText']?.toString().trim();
      if (simpleText != null && RegExp(r'^\d+:\d{2}(:\d{2})?$').hasMatch(simpleText)) {
        final parts = simpleText.split(':').map(int.parse).toList();
        if (parts.length == 2) {
          return (parts[0] * 60 + parts[1]) * 1000;
        } else if (parts.length == 3) {
          return (parts[0] * 3600 + parts[1] * 60 + parts[2]) * 1000;
        }
      }
    }
    return 0;
  }
}
