import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'yt_models.dart';
import 'innertube_parser.dart';

/// Unofficial YouTube Music InnerTube API Client (WEB_REMIX & fallbacks)
class YtClient {
  final Dio dio;
  String? cookie;
  int authUser;
  String? pageId;
  String? visitorData;
  String gl;
  String hl;

  YtClient({
    Dio? dio,
    this.cookie,
    this.authUser = 0,
    this.pageId,
    this.visitorData,
    this.gl = 'VN',
    this.hl = 'vi',
  }) : dio = dio ?? Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  /// Extract a cookie value by key from cookie header string
  static String? extractCookie(String? cookieHeader, String key) {
    if (cookieHeader == null || cookieHeader.isEmpty) return null;
    final pairs = cookieHeader.split(';');
    for (final pair in pairs) {
      final parts = pair.trim().split('=');
      if (parts.length >= 2 && parts[0].trim() == key) {
        return parts.sublist(1).join('=').trim();
      }
    }
    return null;
  }

  /// Compute SAPISIDHASH Authorization header
  /// SAPISIDHASH <ts>_<sha1("<ts> <SAPISID> https://music.youtube.com")>
  static String? computeSapisidHash(String? cookieHeader) {
    if (cookieHeader == null || cookieHeader.isEmpty) return null;
    final sapisid = extractCookie(cookieHeader, 'SAPISID') ??
        extractCookie(cookieHeader, '__Secure-3PAPISID');
    if (sapisid == null || sapisid.isEmpty) return null;

    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    const origin = 'https://music.youtube.com';
    final raw = '$ts $sapisid $origin';
    final digest = sha1.convert(utf8.encode(raw)).toString();
    return 'SAPISIDHASH ${ts}_$digest';
  }

  /// Base headers for InnerTube requests
  Map<String, String> get baseHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
      'X-YouTube-Client-Name': '67', // WEB_REMIX
      'X-YouTube-Client-Version': '1.20260304.03.00',
      'x-origin': 'https://music.youtube.com',
      'Referer': 'https://music.youtube.com/',
      'X-Goog-Authuser': authUser.toString(),
    };

    if (pageId != null && pageId!.isNotEmpty) {
      headers['X-Goog-Pageid'] = pageId!;
    }

    if (cookie != null && cookie!.isNotEmpty) {
      headers['Cookie'] = cookie!;
      final auth = computeSapisidHash(cookie);
      if (auth != null) {
        headers['Authorization'] = auth;
      }
    }

    return headers;
  }

  /// Generate InnerTube context payload
  Map<String, dynamic> buildContext({String clientName = 'WEB_REMIX', String clientVersion = '1.20260304.03.00'}) {
    return {
      'client': {
        'clientName': clientName,
        'clientVersion': clientVersion,
        'gl': gl,
        'hl': hl,
        if (visitorData != null && visitorData!.isNotEmpty) 'visitorData': visitorData,
      }
    };
  }

  static String generateCpn() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
    final rand = Random.secure();
    return List.generate(16, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Get account switcher data to verify cookie and retrieve available brand accounts
  Future<List<YtAccount>> getAccountSwitcher() async {
    const url = 'https://music.youtube.com/getAccountSwitcherEndpoint';
    final response = await dio.get<String>(
      url,
      options: Options(
        headers: baseHeaders,
        responseType: ResponseType.plain,
      ),
    );

    var raw = response.data ?? '';
    if (raw.startsWith(")]}'\n")) {
      raw = raw.substring(5);
    } else if (raw.startsWith(")]}'")) {
      raw = raw.substring(4);
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final accounts = <YtAccount>[];

    // Helper to find all account items recursively
    void findAccountItems(dynamic node) {
      if (node is Map<String, dynamic>) {
        if (node.containsKey('accountItemRenderer')) {
          final item = node['accountItemRenderer'] as Map<String, dynamic>;
          final name = _extractRunsText(item['accountName']) ?? 'Unknown';
          final email = _extractRunsText(item['accountEmail']) ?? '';
          final thumb = _extractThumbnail(item['accountPhoto']);
          final isSelected = item['isSelected'] == true;
          final endpoint = item['serviceEndpoint'] ?? item['navigationEndpoint'];
          final pageId = endpoint?['selectActiveIdentityEndpoint']?['supportedTokens']?[0]?['pageId'] as String?;

          accounts.add(
            YtAccount(
              email: email.isNotEmpty ? email : name,
              name: name,
              thumbUrl: thumb,
              pageId: pageId,
              authUser: authUser,
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

  /// Browse Library Playlists (`FEmusic_liked_playlists`)
  Future<PageResult<YtPlaylist>> getLibraryPlaylistsPage({String? continuation}) async {
    const url = 'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false';
    final body = {
      'context': buildContext(),
      'browseId': 'FEmusic_liked_playlists',
      if (continuation != null) 'continuation': continuation,
    };

    final response = await dio.post<Map<String, dynamic>>(
      url,
      data: body,
      queryParameters: continuation != null ? {'continuation': continuation, 'ctoken': continuation} : null,
      options: Options(headers: baseHeaders),
    );

    return InnerTubeParser.parseLibraryPlaylists(response.data ?? {});
  }

  /// Browse songs in a playlist (`VL<playlistId>`)
  Future<PageResult<YtTrack>> getPlaylistTracksPage(String playlistId, {String? continuation}) async {
    const url = 'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false';
    final browseId = playlistId.startsWith('VL') ? playlistId : 'VL$playlistId';
    final body = {
      'context': buildContext(),
      'browseId': browseId,
      if (continuation != null) 'continuation': continuation,
    };

    final response = await dio.post<Map<String, dynamic>>(
      url,
      data: body,
      queryParameters: continuation != null ? {'continuation': continuation, 'ctoken': continuation} : null,
      options: Options(headers: baseHeaders),
    );

    return InnerTubeParser.parsePlaylistTracks(response.data ?? {});
  }

  /// Legacy list methods for backwards compatibility
  Future<List<YtPlaylist>> getLibraryPlaylists({String? continuation}) async {
    final page = await getLibraryPlaylistsPage(continuation: continuation);
    return page.items;
  }

  Future<List<YtTrack>> getPlaylistTracks(String playlistId, {String? continuation}) async {
    final page = await getPlaylistTracksPage(playlistId, continuation: continuation);
    return page.items;
  }

  /// Search YouTube Music with query, optional filter, and continuation
  Future<PageResult<YtSearchResultItem>> search(
    String query, {
    SearchFilter filter = SearchFilter.all,
    String? continuation,
    CancelToken? cancelToken,
  }) async {
    const url = 'https://music.youtube.com/youtubei/v1/search?prettyPrint=false';
    final body = <String, dynamic>{
      'context': buildContext(),
    };

    if (continuation != null && continuation.isNotEmpty) {
      body['continuation'] = continuation;
    } else {
      body['query'] = query;
      if (filter.param != null && filter.param!.isNotEmpty) {
        body['params'] = filter.param;
      }
    }

    final response = await dio.post<Map<String, dynamic>>(
      url,
      data: body,
      cancelToken: cancelToken,
      options: Options(headers: baseHeaders),
    );

    return InnerTubeParser.parseSearchResults(response.data ?? {});
  }

  /// Query `player` endpoint to obtain stream formats
  Future<List<AudioStreamFormat>> getAudioStreams(
    String videoId, {
    String clientName = 'WEB_REMIX',
    String clientVersion = '1.20260304.03.00',
    String? playlistId,
  }) async {
    const url = 'https://music.youtube.com/youtubei/v1/player?prettyPrint=false';
    final body = {
      'context': buildContext(clientName: clientName, clientVersion: clientVersion),
      'videoId': videoId,
      'cpn': generateCpn(),
      if (playlistId != null) 'playlistId': playlistId,
      'contentCheckOk': true,
      'racyCheckOk': true,
    };

    final response = await dio.post<Map<String, dynamic>>(
      url,
      data: body,
      options: Options(headers: baseHeaders),
    );

    final data = response.data ?? {};
    final status = data['playabilityStatus']?['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      throw Exception('Playability status not OK: $status');
    }

    final streamingData = data['streamingData'] as Map<String, dynamic>?;
    if (streamingData == null) {
      throw Exception('No streamingData returned in player response');
    }

    final formats = <AudioStreamFormat>[];
    final adaptive = streamingData['adaptiveFormats'] as List<dynamic>? ?? [];

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

  // --- Helpers for parsing InnerTube renderers ---

  static String? _extractRunsText(dynamic node) {
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

  static String _extractThumbnail(dynamic node) {
    if (node == null) return '';
    if (node is Map<String, dynamic>) {
      final thumbs = node['thumbnails'] as List<dynamic>? ??
          node['thumbnail']?['thumbnails'] as List<dynamic>? ??
          node['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List<dynamic>?;
      if (thumbs != null && thumbs.isNotEmpty) {
        return thumbs.last['url']?.toString() ?? '';
      }
    }
    return '';
  }
}
