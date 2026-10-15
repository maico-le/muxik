import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/library_repo.dart';
import 'auth_providers.dart';

/// LibraryRepo Provider
final libraryRepoProvider = Provider<LibraryRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final ytClient = ref.watch(ytClientProvider);
  return LibraryRepo(db: db, ytClient: ytClient);
});

/// Local cached playlists stream
final localPlaylistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(libraryRepoProvider);
  return repo.watchLocalPlaylists();
});

/// Local cached tracks stream for a playlist
final playlistTracksStreamProvider =
    StreamProvider.family<List<Track>, String>((ref, playlistId) {
  final repo = ref.watch(libraryRepoProvider);
  return repo.watchPlaylistTracks(playlistId);
});

/// Single playlist metadata provider
final playlistMetaProvider =
    FutureProvider.family<Playlist?, String>((ref, playlistId) {
  final repo = ref.watch(libraryRepoProvider);
  return repo.getPlaylist(playlistId);
});
