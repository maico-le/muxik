import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// --- TABLE DEFINITIONS AS SPECIFIED IN PROMPT.MD SECTION 10 ---

/// Accounts table (cookie stored in secure storage keyed by email)
class Accounts extends Table {
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get thumbUrl => text().nullable()();
  TextColumn get pageId => text().nullable()();
  IntColumn get authUser => integer().withDefault(const Constant(0))();
  BoolColumn get isUsed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {email};
}

/// Tracks table
class Tracks extends Table {
  TextColumn get videoId => text()();
  TextColumn get title => text()();
  TextColumn get artists => text()(); // Comma-separated or JSON list
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get thumbUrl => text().nullable()();
  BoolColumn get isPlayable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {videoId};
}

/// Playlists table
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get thumbUrl => text().nullable()();
  TextColumn get owner => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('youtube'))(); // youtube | local
  TextColumn get privacy => text().withDefault(const Constant('PUBLIC'))(); // PUBLIC | PRIVATE | UNLISTED
  IntColumn get trackCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get etag => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Playlist-to-Track mapping table preserving order
class PlaylistTracks extends Table {
  TextColumn get playlistId => text()();
  IntColumn get position => integer()();
  TextColumn get videoId => text()();
  TextColumn get setVideoId => text().nullable()();

  @override
  Set<Column> get primaryKey => {playlistId, position};
}

/// Pending offline mutations to push when connected
class PendingOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // e.g. add_track, remove_track, create_playlist
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Player Queue State persistence for app restart restoration
class QueueState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get trackIdsJson => text()(); // JSON list of videoIds
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get shuffleOn => boolean().withDefault(const Constant(false))();
  TextColumn get loopMode => text().withDefault(const Constant('OFF'))(); // OFF | ONE | ALL | ONE_X_N
  IntColumn get loopCount => integer().withDefault(const Constant(3))(); // for ONE_X_N

  @override
  Set<Column> get primaryKey => {id};
}

/// Local file cache index (keyed by videoId + itag)
class CacheIndex extends Table {
  TextColumn get videoId => text()();
  IntColumn get itag => integer()();
  TextColumn get path => text()();
  IntColumn get bytes => integer()();
  DateTimeColumn get lastAccess => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {videoId, itag};
}

/// Data usage meter entries
class DataUsage extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get day => dateTime()();
  TextColumn get network => text()(); // wifi | cell
  TextColumn get kind => text()(); // audio | image | api
  IntColumn get bytes => integer()();
}

/// Search history table
class SearchHistory extends Table {
  TextColumn get query => text()();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {query};
}

@DriftDatabase(tables: [
  Accounts,
  Tracks,
  Playlists,
  PlaylistTracks,
  PendingOps,
  QueueState,
  CacheIndex,
  DataUsage,
  SearchHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'musical.sqlite'));
    return NativeDatabase(file);
  });
}
