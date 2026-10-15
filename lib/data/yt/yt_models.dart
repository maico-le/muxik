/// Represents a Google/YouTube account extracted from getAccountSwitcherEndpoint
class YtAccount {
  final String email;
  final String name;
  final String? thumbUrl;
  final String? pageId;
  final int authUser;
  final bool isUsed;

  const YtAccount({
    required this.email,
    required this.name,
    this.thumbUrl,
    this.pageId,
    this.authUser = 0,
    this.isUsed = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'thumbUrl': thumbUrl,
    'pageId': pageId,
    'authUser': authUser,
    'isUsed': isUsed,
  };

  factory YtAccount.fromJson(Map<String, dynamic> json) => YtAccount(
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    thumbUrl: json['thumbUrl'] as String? ?? '',
    pageId: json['pageId'] as String?,
    authUser: json['authUser'] as int? ?? 0,
    isUsed: json['isUsed'] as bool? ?? false,
  );
}

/// A playlist item from InnerTube (e.g. Liked Playlists)
class YtPlaylist {
  final String id;
  final String title;
  final String thumbUrl;
  final String? owner;
  final int trackCount;
  final String? continuation;

  const YtPlaylist({
    required this.id,
    required this.title,
    required this.thumbUrl,
    this.owner,
    this.trackCount = 0,
    this.continuation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'thumbUrl': thumbUrl,
    'owner': owner,
    'trackCount': trackCount,
    'continuation': continuation,
  };

  factory YtPlaylist.fromJson(Map<String, dynamic> json) => YtPlaylist(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    thumbUrl: json['thumbUrl'] as String? ?? '',
    owner: json['owner'] as String?,
    trackCount: json['trackCount'] as int? ?? 0,
    continuation: json['continuation'] as String?,
  );
}

/// A music track in YouTube Music
class YtTrack {
  final String videoId;
  final String title;
  final List<String> artists;
  final String? album;
  final int durationMs;
  final String thumbUrl;
  final bool isPlayable;
  final String? setVideoId;

  const YtTrack({
    required this.videoId,
    required this.title,
    required this.artists,
    this.album,
    required this.durationMs,
    required this.thumbUrl,
    this.isPlayable = true,
    this.setVideoId,
  });

  String get artistsDisplay => artists.isEmpty ? 'Unknown Artist' : artists.join(', ');

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'artists': artists,
    'album': album,
    'durationMs': durationMs,
    'thumbUrl': thumbUrl,
    'isPlayable': isPlayable,
    'setVideoId': setVideoId,
  };

  factory YtTrack.fromJson(Map<String, dynamic> json) => YtTrack(
    videoId: json['videoId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    artists: (json['artists'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    album: json['album'] as String?,
    durationMs: json['durationMs'] as int? ?? 0,
    thumbUrl: json['thumbUrl'] as String? ?? '',
    isPlayable: json['isPlayable'] as bool? ?? true,
    setVideoId: json['setVideoId'] as String?,
  );
}

/// Audio format stream returned from `player` adaptiveFormats
class AudioStreamFormat {
  final int itag;
  final String mimeType;
  final int bitrate;
  final int? sampleRate;
  final int? contentLength;
  final String? url;
  final String? signatureCipher;
  final double? loudnessDb;

  const AudioStreamFormat({
    required this.itag,
    required this.mimeType,
    required this.bitrate,
    this.sampleRate,
    this.contentLength,
    this.url,
    this.signatureCipher,
    this.loudnessDb,
  });

  bool get isOpus => mimeType.contains('audio/webm') || mimeType.contains('opus');
  bool get isAac => mimeType.contains('audio/mp4') || mimeType.contains('mp4a');

  factory AudioStreamFormat.fromJson(Map<String, dynamic> json) {
    return AudioStreamFormat(
      itag: json['itag'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? (json['averageBitrate'] as int? ?? 0),
      sampleRate: int.tryParse(json['audioSampleRate']?.toString() ?? ''),
      contentLength: int.tryParse(json['contentLength']?.toString() ?? ''),
      url: json['url'] as String?,
      signatureCipher: (json['signatureCipher'] ?? json['cipher']) as String?,
      loudnessDb: (json['loudnessDb'] as num?)?.toDouble(),
    );
  }
}

/// Successfully resolved stream ready for audio player
class ResolvedStream {
  final String videoId;
  final String url;
  final String mimeType;
  final int itag;
  final int bitrate;
  final int? contentLength;
  final DateTime expiresAt;
  final double? loudnessDb;

  const ResolvedStream({
    required this.videoId,
    required this.url,
    required this.mimeType,
    required this.itag,
    required this.bitrate,
    this.contentLength,
    required this.expiresAt,
    this.loudnessDb,
  });

  bool get isExpired {
    // Expire 5 minutes early to avoid playback interruptions
    return DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
  }
}

/// Filter options for YouTube Music search
enum SearchFilter {
  all(null, 'TẤT CẢ'),
  songs('EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D', 'BÀI HÁT'),
  videos('EgWKAQIQAWoKEAkQChAFEAMQBA%3D%3D', 'VIDEO'),
  albums('EgWKAQIYAWoKEAkQChAFEAMQBA%3D%3D', 'ALBUM'),
  artists('EgWKAQIgAWoKEAkQChAFEAMQBA%3D%3D', 'NGHỆ SĨ'),
  playlists('EgWKAQIoAWoKEAkQChAFEAMQBA%3D%3D', 'PLAYLIST');

  final String? param;
  final String label;
  const SearchFilter(this.param, this.label);
}

/// Types of items returned in search results
enum SearchResultType { song, video, album, artist, playlist, unknown }

/// Item in YouTube Music search results
class YtSearchResultItem {
  final String id; // videoId, browseId, or playlistId
  final String title;
  final SearchResultType type;
  final List<String> artists;
  final String? album;
  final int durationMs;
  final String thumbUrl;

  const YtSearchResultItem({
    required this.id,
    required this.title,
    required this.type,
    this.artists = const [],
    this.album,
    this.durationMs = 0,
    this.thumbUrl = '',
  });

  bool get isPlayable => type == SearchResultType.song || type == SearchResultType.video;

  String get subtitle {
    final parts = <String>[];
    if (artists.isNotEmpty) parts.add(artists.join(', '));
    if (album != null && album!.isNotEmpty) parts.add(album!);
    if (durationMs > 0) {
      final s = (durationMs / 1000).round();
      final m = s ~/ 60;
      final remS = s % 60;
      parts.add('$m:${remS.toString().padLeft(2, '0')}');
    }
    return parts.join(' • ');
  }

  YtTrack toYtTrack() {
    return YtTrack(
      videoId: id,
      title: title,
      artists: artists,
      album: album,
      durationMs: durationMs,
      thumbUrl: thumbUrl,
    );
  }
}
