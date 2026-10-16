import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;
import 'yt_client.dart';
import 'yt_models.dart';

/// Authenticated & modern HTTP client for YoutubeExplode preventing bot-blocks
class AuthenticatedYoutubeHttpClient extends yt_explode.YoutubeHttpClient {
  final String? cookie;
  AuthenticatedYoutubeHttpClient([this.cookie, http.Client? client]) : super(client);

  @override
  Map<String, String> get headers => {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
    'cookie': cookie != null && cookie!.isNotEmpty
        ? '$cookie; SOCS=CAI; PREF=hl=en; GPS=1; CONSENT=YES+cb'
        : 'CONSENT=YES+cb; SOCS=CAI; PREF=hl=en; GPS=1',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'en-US,en;q=0.5',
  };
}

/// Resolves playable audio streams with quality policies and fallbacks
class StreamResolver {
  final YtClient ytClient;
  final Map<String, ResolvedStream> _cache = {};

  StreamResolver({required this.ytClient});

  /// Clear in-memory stream cache
  void clearCache() => _cache.clear();

  /// Remove a specific video from cache (e.g. if stream expired or playback failed)
  void remove(String videoId) => _cache.remove(videoId);

  /// Resolve a stream URL for [videoId].
  /// [preferLowBitrate]: if true, picks lowest playable audio (Opus/AAC ~48kbps) to conserve data on cellular networks.
  Future<ResolvedStream> resolve(
    String videoId, {
    bool preferLowBitrate = false,
    String? playlistId,
  }) async {
    // 1. Check valid cached stream
    final cached = _cache[videoId];
    if (cached != null && !cached.isExpired) {
      return cached;
    }

    // 2. Try InnerTube clients in priority sequence
    const clientCandidates = [
      ('WEB_REMIX', '1.20260304.03.00'),
      ('ANDROID_MUSIC', '7.27.52'),
      ('IOS', '19.45.4'),
      ('TVHTML5', '7.20250312.16.00'),
    ];

    for (final (clientName, clientVersion) in clientCandidates) {
      try {
        final formats = await ytClient.getAudioStreams(
          videoId,
          clientName: clientName,
          clientVersion: clientVersion,
          playlistId: playlistId,
        );

        if (formats.isNotEmpty) {
          final withUrl = formats.where((f) => f.url != null && f.url!.isNotEmpty).toList();
          final selected = _selectFormat(withUrl, preferLowBitrate: preferLowBitrate);
          if (selected != null && selected.url != null && selected.url!.isNotEmpty) {
            final expiresAt = _parseExpiry(selected.url!) ??
                DateTime.now().add(const Duration(hours: 4));

            final resolved = ResolvedStream(
              videoId: videoId,
              url: selected.url!,
              mimeType: selected.mimeType,
              itag: selected.itag,
              bitrate: selected.bitrate,
              contentLength: selected.contentLength,
              expiresAt: expiresAt,
              loudnessDb: selected.loudnessDb,
            );

            _cache[videoId] = resolved;
            return resolved;
          }

          // InnerTube returned formats but none had plain URLs (requires signature deciphering).
          // Break immediately to decipherer fallback without wasting seconds on other clients.
          break;
        }
      } catch (_) {
        // Fallback to next client
        continue;
      }
    }

    // 3. Fallback: youtube_explode_dart cipher decipherer
    return await _resolveWithYoutubeExplode(videoId, preferLowBitrate: preferLowBitrate);
  }

  /// Select the optimal audio format according to data-saving policy
  AudioStreamFormat? _selectFormat(
    List<AudioStreamFormat> formats, {
    required bool preferLowBitrate,
  }) {
    if (formats.isEmpty) return null;

    if (preferLowBitrate) {
      // Cellular mode: Lowest acceptable bitrate >= 45kbps (itag 249/250 or 139)
      final candidates = formats.where((f) => f.bitrate >= 45000).toList();
      candidates.sort((a, b) => a.bitrate.compareTo(b.bitrate));
      if (candidates.isNotEmpty) {
        // Prefer opus over aac when equal/similar
        return candidates.firstWhere((f) => f.isOpus, orElse: () => candidates.first);
      }
      // If none >= 45kbps, take lowest available
      formats.sort((a, b) => a.bitrate.compareTo(b.bitrate));
      return formats.first;
    } else {
      // Wi-Fi mode: High quality (itag 251 ~160kbps opus or 140 ~128kbps aac)
      final candidates = List<AudioStreamFormat>.from(formats);
      candidates.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      return candidates.firstWhere((f) => f.isOpus, orElse: () => candidates.first);
    }
  }

  /// Fallback resolver using youtube_explode_dart with multi-tier client fallbacks
  Future<ResolvedStream> _resolveWithYoutubeExplode(
    String videoId, {
    required bool preferLowBitrate,
  }) async {
    dynamic lastError;
    final ytClientsPriority = [
      // Primary: Mobile & TV clients without watch page (bypasses bot-block & rate-limiting, resolves in ~3s)
      [
        yt_explode.YoutubeApiClient.ios,
        yt_explode.YoutubeApiClient.tv,
        yt_explode.YoutubeApiClient.androidSdkless,
      ],
      // Fallback: Android & Safari
      [
        yt_explode.YoutubeApiClient.android,
        yt_explode.YoutubeApiClient.safari,
      ],
      // Last resort: Clean web client
      null,
    ];

    for (final clients in ytClientsPriority) {
      final client = (ytClient.cookie != null && ytClient.cookie!.isNotEmpty)
          ? AuthenticatedYoutubeHttpClient(ytClient.cookie)
          : null;
      final yt = yt_explode.YoutubeExplode(httpClient: client);
      try {
        final yt_explode.StreamManifest manifest;
        if (clients != null) {
          manifest = await yt.videos.streamsClient.getManifest(
            videoId,
            ytClients: clients,
            requireWatchPage: false,
          );
        } else {
          manifest = await yt.videos.streamsClient.getManifest(
            videoId,
            requireWatchPage: false,
          );
        }
        final audioStreams = manifest.audioOnly.toList();

        if (audioStreams.isEmpty) {
          throw Exception('No audio-only streams found for $videoId');
        }

        final playable = audioStreams
            .where((s) => s.tag != 599 && s.tag != 600 && s.bitrate.bitsPerSecond >= 40000)
            .toList();
        final pool = playable.isNotEmpty ? playable : audioStreams;

        if (preferLowBitrate) {
          pool.sort((a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond));
        } else {
          pool.sort((a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
        }

        final chosen = pool.first;
        final streamUrl = chosen.url.toString();
        final expiresAt = _parseExpiry(streamUrl) ?? DateTime.now().add(const Duration(hours: 4));

        final resolved = ResolvedStream(
          videoId: videoId,
          url: streamUrl,
          mimeType: chosen.container.name,
          itag: chosen.tag,
          bitrate: chosen.bitrate.bitsPerSecond,
          contentLength: chosen.size.totalBytes,
          expiresAt: expiresAt,
        );

        _cache[videoId] = resolved;
        return resolved;
      } catch (e) {
        lastError = e;
      } finally {
        yt.close();
      }
    }
    throw lastError ?? Exception('Failed to resolve stream for $videoId');
  }

  /// Parse the URL's `expire` query parameter
  DateTime? _parseExpiry(String url) {
    final match = RegExp(r'[?&]expire=(\d+)').firstMatch(url);
    if (match != null) {
      final sec = int.tryParse(match.group(1)!);
      if (sec != null) {
        return DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      }
    }
    return null;
  }
}
