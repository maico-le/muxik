// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbUrlMeta =
      const VerificationMeta('thumbUrl');
  @override
  late final GeneratedColumn<String> thumbUrl = GeneratedColumn<String>(
      'thumb_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
      'page_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authUserMeta =
      const VerificationMeta('authUser');
  @override
  late final GeneratedColumn<int> authUser = GeneratedColumn<int>(
      'auth_user', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isUsedMeta = const VerificationMeta('isUsed');
  @override
  late final GeneratedColumn<bool> isUsed = GeneratedColumn<bool>(
      'is_used', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_used" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [email, name, thumbUrl, pageId, authUser, isUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('thumb_url')) {
      context.handle(_thumbUrlMeta,
          thumbUrl.isAcceptableOrUnknown(data['thumb_url']!, _thumbUrlMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    }
    if (data.containsKey('auth_user')) {
      context.handle(_authUserMeta,
          authUser.isAcceptableOrUnknown(data['auth_user']!, _authUserMeta));
    }
    if (data.containsKey('is_used')) {
      context.handle(_isUsedMeta,
          isUsed.isAcceptableOrUnknown(data['is_used']!, _isUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {email};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      thumbUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumb_url']),
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_id']),
      authUser: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auth_user'])!,
      isUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_used'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String email;
  final String name;
  final String? thumbUrl;
  final String? pageId;
  final int authUser;
  final bool isUsed;
  const Account(
      {required this.email,
      required this.name,
      this.thumbUrl,
      this.pageId,
      required this.authUser,
      required this.isUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || thumbUrl != null) {
      map['thumb_url'] = Variable<String>(thumbUrl);
    }
    if (!nullToAbsent || pageId != null) {
      map['page_id'] = Variable<String>(pageId);
    }
    map['auth_user'] = Variable<int>(authUser);
    map['is_used'] = Variable<bool>(isUsed);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      email: Value(email),
      name: Value(name),
      thumbUrl: thumbUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbUrl),
      pageId:
          pageId == null && nullToAbsent ? const Value.absent() : Value(pageId),
      authUser: Value(authUser),
      isUsed: Value(isUsed),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      thumbUrl: serializer.fromJson<String?>(json['thumbUrl']),
      pageId: serializer.fromJson<String?>(json['pageId']),
      authUser: serializer.fromJson<int>(json['authUser']),
      isUsed: serializer.fromJson<bool>(json['isUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'thumbUrl': serializer.toJson<String?>(thumbUrl),
      'pageId': serializer.toJson<String?>(pageId),
      'authUser': serializer.toJson<int>(authUser),
      'isUsed': serializer.toJson<bool>(isUsed),
    };
  }

  Account copyWith(
          {String? email,
          String? name,
          Value<String?> thumbUrl = const Value.absent(),
          Value<String?> pageId = const Value.absent(),
          int? authUser,
          bool? isUsed}) =>
      Account(
        email: email ?? this.email,
        name: name ?? this.name,
        thumbUrl: thumbUrl.present ? thumbUrl.value : this.thumbUrl,
        pageId: pageId.present ? pageId.value : this.pageId,
        authUser: authUser ?? this.authUser,
        isUsed: isUsed ?? this.isUsed,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      thumbUrl: data.thumbUrl.present ? data.thumbUrl.value : this.thumbUrl,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      authUser: data.authUser.present ? data.authUser.value : this.authUser,
      isUsed: data.isUsed.present ? data.isUsed.value : this.isUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('pageId: $pageId, ')
          ..write('authUser: $authUser, ')
          ..write('isUsed: $isUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(email, name, thumbUrl, pageId, authUser, isUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.email == this.email &&
          other.name == this.name &&
          other.thumbUrl == this.thumbUrl &&
          other.pageId == this.pageId &&
          other.authUser == this.authUser &&
          other.isUsed == this.isUsed);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> email;
  final Value<String> name;
  final Value<String?> thumbUrl;
  final Value<String?> pageId;
  final Value<int> authUser;
  final Value<bool> isUsed;
  final Value<int> rowid;
  const AccountsCompanion({
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    this.pageId = const Value.absent(),
    this.authUser = const Value.absent(),
    this.isUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String email,
    required String name,
    this.thumbUrl = const Value.absent(),
    this.pageId = const Value.absent(),
    this.authUser = const Value.absent(),
    this.isUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : email = Value(email),
        name = Value(name);
  static Insertable<Account> custom({
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? thumbUrl,
    Expression<String>? pageId,
    Expression<int>? authUser,
    Expression<bool>? isUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (pageId != null) 'page_id': pageId,
      if (authUser != null) 'auth_user': authUser,
      if (isUsed != null) 'is_used': isUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? email,
      Value<String>? name,
      Value<String?>? thumbUrl,
      Value<String?>? pageId,
      Value<int>? authUser,
      Value<bool>? isUsed,
      Value<int>? rowid}) {
    return AccountsCompanion(
      email: email ?? this.email,
      name: name ?? this.name,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      pageId: pageId ?? this.pageId,
      authUser: authUser ?? this.authUser,
      isUsed: isUsed ?? this.isUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (thumbUrl.present) {
      map['thumb_url'] = Variable<String>(thumbUrl.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (authUser.present) {
      map['auth_user'] = Variable<int>(authUser.value);
    }
    if (isUsed.present) {
      map['is_used'] = Variable<bool>(isUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('pageId: $pageId, ')
          ..write('authUser: $authUser, ')
          ..write('isUsed: $isUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _videoIdMeta =
      const VerificationMeta('videoId');
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
      'video_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistsMeta =
      const VerificationMeta('artists');
  @override
  late final GeneratedColumn<String> artists = GeneratedColumn<String>(
      'artists', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
      'album', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _thumbUrlMeta =
      const VerificationMeta('thumbUrl');
  @override
  late final GeneratedColumn<String> thumbUrl = GeneratedColumn<String>(
      'thumb_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPlayableMeta =
      const VerificationMeta('isPlayable');
  @override
  late final GeneratedColumn<bool> isPlayable = GeneratedColumn<bool>(
      'is_playable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_playable" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastPlayedAtMeta =
      const VerificationMeta('lastPlayedAt');
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
      'last_played_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        videoId,
        title,
        artists,
        album,
        durationMs,
        thumbUrl,
        isPlayable,
        lastPlayedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(Insertable<Track> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('video_id')) {
      context.handle(_videoIdMeta,
          videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta));
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artists')) {
      context.handle(_artistsMeta,
          artists.isAcceptableOrUnknown(data['artists']!, _artistsMeta));
    } else if (isInserting) {
      context.missing(_artistsMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('thumb_url')) {
      context.handle(_thumbUrlMeta,
          thumbUrl.isAcceptableOrUnknown(data['thumb_url']!, _thumbUrlMeta));
    }
    if (data.containsKey('is_playable')) {
      context.handle(
          _isPlayableMeta,
          isPlayable.isAcceptableOrUnknown(
              data['is_playable']!, _isPlayableMeta));
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
          _lastPlayedAtMeta,
          lastPlayedAt.isAcceptableOrUnknown(
              data['last_played_at']!, _lastPlayedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {videoId};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      videoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artists: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artists'])!,
      album: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      thumbUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumb_url']),
      isPlayable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_playable'])!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_played_at']),
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final String videoId;
  final String title;
  final String artists;
  final String? album;
  final int durationMs;
  final String? thumbUrl;
  final bool isPlayable;
  final DateTime? lastPlayedAt;
  const Track(
      {required this.videoId,
      required this.title,
      required this.artists,
      this.album,
      required this.durationMs,
      this.thumbUrl,
      required this.isPlayable,
      this.lastPlayedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['video_id'] = Variable<String>(videoId);
    map['title'] = Variable<String>(title);
    map['artists'] = Variable<String>(artists);
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || thumbUrl != null) {
      map['thumb_url'] = Variable<String>(thumbUrl);
    }
    map['is_playable'] = Variable<bool>(isPlayable);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      videoId: Value(videoId),
      title: Value(title),
      artists: Value(artists),
      album:
          album == null && nullToAbsent ? const Value.absent() : Value(album),
      durationMs: Value(durationMs),
      thumbUrl: thumbUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbUrl),
      isPlayable: Value(isPlayable),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
    );
  }

  factory Track.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      videoId: serializer.fromJson<String>(json['videoId']),
      title: serializer.fromJson<String>(json['title']),
      artists: serializer.fromJson<String>(json['artists']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      thumbUrl: serializer.fromJson<String?>(json['thumbUrl']),
      isPlayable: serializer.fromJson<bool>(json['isPlayable']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'videoId': serializer.toJson<String>(videoId),
      'title': serializer.toJson<String>(title),
      'artists': serializer.toJson<String>(artists),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int>(durationMs),
      'thumbUrl': serializer.toJson<String?>(thumbUrl),
      'isPlayable': serializer.toJson<bool>(isPlayable),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
    };
  }

  Track copyWith(
          {String? videoId,
          String? title,
          String? artists,
          Value<String?> album = const Value.absent(),
          int? durationMs,
          Value<String?> thumbUrl = const Value.absent(),
          bool? isPlayable,
          Value<DateTime?> lastPlayedAt = const Value.absent()}) =>
      Track(
        videoId: videoId ?? this.videoId,
        title: title ?? this.title,
        artists: artists ?? this.artists,
        album: album.present ? album.value : this.album,
        durationMs: durationMs ?? this.durationMs,
        thumbUrl: thumbUrl.present ? thumbUrl.value : this.thumbUrl,
        isPlayable: isPlayable ?? this.isPlayable,
        lastPlayedAt:
            lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
      );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      title: data.title.present ? data.title.value : this.title,
      artists: data.artists.present ? data.artists.value : this.artists,
      album: data.album.present ? data.album.value : this.album,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      thumbUrl: data.thumbUrl.present ? data.thumbUrl.value : this.thumbUrl,
      isPlayable:
          data.isPlayable.present ? data.isPlayable.value : this.isPlayable,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('videoId: $videoId, ')
          ..write('title: $title, ')
          ..write('artists: $artists, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('isPlayable: $isPlayable, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(videoId, title, artists, album, durationMs,
      thumbUrl, isPlayable, lastPlayedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.videoId == this.videoId &&
          other.title == this.title &&
          other.artists == this.artists &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.thumbUrl == this.thumbUrl &&
          other.isPlayable == this.isPlayable &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<String> videoId;
  final Value<String> title;
  final Value<String> artists;
  final Value<String?> album;
  final Value<int> durationMs;
  final Value<String?> thumbUrl;
  final Value<bool> isPlayable;
  final Value<DateTime?> lastPlayedAt;
  final Value<int> rowid;
  const TracksCompanion({
    this.videoId = const Value.absent(),
    this.title = const Value.absent(),
    this.artists = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    this.isPlayable = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String videoId,
    required String title,
    required String artists,
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    this.isPlayable = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : videoId = Value(videoId),
        title = Value(title),
        artists = Value(artists);
  static Insertable<Track> custom({
    Expression<String>? videoId,
    Expression<String>? title,
    Expression<String>? artists,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<String>? thumbUrl,
    Expression<bool>? isPlayable,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (videoId != null) 'video_id': videoId,
      if (title != null) 'title': title,
      if (artists != null) 'artists': artists,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (isPlayable != null) 'is_playable': isPlayable,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith(
      {Value<String>? videoId,
      Value<String>? title,
      Value<String>? artists,
      Value<String?>? album,
      Value<int>? durationMs,
      Value<String?>? thumbUrl,
      Value<bool>? isPlayable,
      Value<DateTime?>? lastPlayedAt,
      Value<int>? rowid}) {
    return TracksCompanion(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      isPlayable: isPlayable ?? this.isPlayable,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artists.present) {
      map['artists'] = Variable<String>(artists.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (thumbUrl.present) {
      map['thumb_url'] = Variable<String>(thumbUrl.value);
    }
    if (isPlayable.present) {
      map['is_playable'] = Variable<bool>(isPlayable.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('videoId: $videoId, ')
          ..write('title: $title, ')
          ..write('artists: $artists, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('isPlayable: $isPlayable, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbUrlMeta =
      const VerificationMeta('thumbUrl');
  @override
  late final GeneratedColumn<String> thumbUrl = GeneratedColumn<String>(
      'thumb_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
      'owner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('youtube'));
  static const VerificationMeta _privacyMeta =
      const VerificationMeta('privacy');
  @override
  late final GeneratedColumn<String> privacy = GeneratedColumn<String>(
      'privacy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PUBLIC'));
  static const VerificationMeta _trackCountMeta =
      const VerificationMeta('trackCount');
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
      'track_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
      'etag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, thumbUrl, owner, source, privacy, trackCount, syncedAt, etag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumb_url')) {
      context.handle(_thumbUrlMeta,
          thumbUrl.isAcceptableOrUnknown(data['thumb_url']!, _thumbUrlMeta));
    }
    if (data.containsKey('owner')) {
      context.handle(
          _ownerMeta, owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('privacy')) {
      context.handle(_privacyMeta,
          privacy.isAcceptableOrUnknown(data['privacy']!, _privacyMeta));
    }
    if (data.containsKey('track_count')) {
      context.handle(
          _trackCountMeta,
          trackCount.isAcceptableOrUnknown(
              data['track_count']!, _trackCountMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('etag')) {
      context.handle(
          _etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      thumbUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumb_url']),
      owner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      privacy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}privacy'])!,
      trackCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_count'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      etag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}etag']),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String id;
  final String title;
  final String? thumbUrl;
  final String? owner;
  final String source;
  final String privacy;
  final int trackCount;
  final DateTime? syncedAt;
  final String? etag;
  const Playlist(
      {required this.id,
      required this.title,
      this.thumbUrl,
      this.owner,
      required this.source,
      required this.privacy,
      required this.trackCount,
      this.syncedAt,
      this.etag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || thumbUrl != null) {
      map['thumb_url'] = Variable<String>(thumbUrl);
    }
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    map['source'] = Variable<String>(source);
    map['privacy'] = Variable<String>(privacy);
    map['track_count'] = Variable<int>(trackCount);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      title: Value(title),
      thumbUrl: thumbUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbUrl),
      owner:
          owner == null && nullToAbsent ? const Value.absent() : Value(owner),
      source: Value(source),
      privacy: Value(privacy),
      trackCount: Value(trackCount),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      thumbUrl: serializer.fromJson<String?>(json['thumbUrl']),
      owner: serializer.fromJson<String?>(json['owner']),
      source: serializer.fromJson<String>(json['source']),
      privacy: serializer.fromJson<String>(json['privacy']),
      trackCount: serializer.fromJson<int>(json['trackCount']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      etag: serializer.fromJson<String?>(json['etag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'thumbUrl': serializer.toJson<String?>(thumbUrl),
      'owner': serializer.toJson<String?>(owner),
      'source': serializer.toJson<String>(source),
      'privacy': serializer.toJson<String>(privacy),
      'trackCount': serializer.toJson<int>(trackCount),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'etag': serializer.toJson<String?>(etag),
    };
  }

  Playlist copyWith(
          {String? id,
          String? title,
          Value<String?> thumbUrl = const Value.absent(),
          Value<String?> owner = const Value.absent(),
          String? source,
          String? privacy,
          int? trackCount,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<String?> etag = const Value.absent()}) =>
      Playlist(
        id: id ?? this.id,
        title: title ?? this.title,
        thumbUrl: thumbUrl.present ? thumbUrl.value : this.thumbUrl,
        owner: owner.present ? owner.value : this.owner,
        source: source ?? this.source,
        privacy: privacy ?? this.privacy,
        trackCount: trackCount ?? this.trackCount,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        etag: etag.present ? etag.value : this.etag,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      thumbUrl: data.thumbUrl.present ? data.thumbUrl.value : this.thumbUrl,
      owner: data.owner.present ? data.owner.value : this.owner,
      source: data.source.present ? data.source.value : this.source,
      privacy: data.privacy.present ? data.privacy.value : this.privacy,
      trackCount:
          data.trackCount.present ? data.trackCount.value : this.trackCount,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      etag: data.etag.present ? data.etag.value : this.etag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('owner: $owner, ')
          ..write('source: $source, ')
          ..write('privacy: $privacy, ')
          ..write('trackCount: $trackCount, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('etag: $etag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, thumbUrl, owner, source, privacy, trackCount, syncedAt, etag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.title == this.title &&
          other.thumbUrl == this.thumbUrl &&
          other.owner == this.owner &&
          other.source == this.source &&
          other.privacy == this.privacy &&
          other.trackCount == this.trackCount &&
          other.syncedAt == this.syncedAt &&
          other.etag == this.etag);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> thumbUrl;
  final Value<String?> owner;
  final Value<String> source;
  final Value<String> privacy;
  final Value<int> trackCount;
  final Value<DateTime?> syncedAt;
  final Value<String?> etag;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbUrl = const Value.absent(),
    this.owner = const Value.absent(),
    this.source = const Value.absent(),
    this.privacy = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String title,
    this.thumbUrl = const Value.absent(),
    this.owner = const Value.absent(),
    this.source = const Value.absent(),
    this.privacy = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? thumbUrl,
    Expression<String>? owner,
    Expression<String>? source,
    Expression<String>? privacy,
    Expression<int>? trackCount,
    Expression<DateTime>? syncedAt,
    Expression<String>? etag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (owner != null) 'owner': owner,
      if (source != null) 'source': source,
      if (privacy != null) 'privacy': privacy,
      if (trackCount != null) 'track_count': trackCount,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (etag != null) 'etag': etag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? thumbUrl,
      Value<String?>? owner,
      Value<String>? source,
      Value<String>? privacy,
      Value<int>? trackCount,
      Value<DateTime?>? syncedAt,
      Value<String?>? etag,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      owner: owner ?? this.owner,
      source: source ?? this.source,
      privacy: privacy ?? this.privacy,
      trackCount: trackCount ?? this.trackCount,
      syncedAt: syncedAt ?? this.syncedAt,
      etag: etag ?? this.etag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbUrl.present) {
      map['thumb_url'] = Variable<String>(thumbUrl.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (privacy.present) {
      map['privacy'] = Variable<String>(privacy.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('thumbUrl: $thumbUrl, ')
          ..write('owner: $owner, ')
          ..write('source: $source, ')
          ..write('privacy: $privacy, ')
          ..write('trackCount: $trackCount, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('etag: $etag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTable extends PlaylistTracks
    with TableInfo<$PlaylistTracksTable, PlaylistTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _videoIdMeta =
      const VerificationMeta('videoId');
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
      'video_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setVideoIdMeta =
      const VerificationMeta('setVideoId');
  @override
  late final GeneratedColumn<String> setVideoId = GeneratedColumn<String>(
      'set_video_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [playlistId, position, videoId, setVideoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistTrack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(_videoIdMeta,
          videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta));
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('set_video_id')) {
      context.handle(
          _setVideoIdMeta,
          setVideoId.isAcceptableOrUnknown(
              data['set_video_id']!, _setVideoIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  PlaylistTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrack(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      videoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_id'])!,
      setVideoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_video_id']),
    );
  }

  @override
  $PlaylistTracksTable createAlias(String alias) {
    return $PlaylistTracksTable(attachedDatabase, alias);
  }
}

class PlaylistTrack extends DataClass implements Insertable<PlaylistTrack> {
  final String playlistId;
  final int position;
  final String videoId;
  final String? setVideoId;
  const PlaylistTrack(
      {required this.playlistId,
      required this.position,
      required this.videoId,
      this.setVideoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['position'] = Variable<int>(position);
    map['video_id'] = Variable<String>(videoId);
    if (!nullToAbsent || setVideoId != null) {
      map['set_video_id'] = Variable<String>(setVideoId);
    }
    return map;
  }

  PlaylistTracksCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksCompanion(
      playlistId: Value(playlistId),
      position: Value(position),
      videoId: Value(videoId),
      setVideoId: setVideoId == null && nullToAbsent
          ? const Value.absent()
          : Value(setVideoId),
    );
  }

  factory PlaylistTrack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrack(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      position: serializer.fromJson<int>(json['position']),
      videoId: serializer.fromJson<String>(json['videoId']),
      setVideoId: serializer.fromJson<String?>(json['setVideoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'position': serializer.toJson<int>(position),
      'videoId': serializer.toJson<String>(videoId),
      'setVideoId': serializer.toJson<String?>(setVideoId),
    };
  }

  PlaylistTrack copyWith(
          {String? playlistId,
          int? position,
          String? videoId,
          Value<String?> setVideoId = const Value.absent()}) =>
      PlaylistTrack(
        playlistId: playlistId ?? this.playlistId,
        position: position ?? this.position,
        videoId: videoId ?? this.videoId,
        setVideoId: setVideoId.present ? setVideoId.value : this.setVideoId,
      );
  PlaylistTrack copyWithCompanion(PlaylistTracksCompanion data) {
    return PlaylistTrack(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      position: data.position.present ? data.position.value : this.position,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      setVideoId:
          data.setVideoId.present ? data.setVideoId.value : this.setVideoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrack(')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('videoId: $videoId, ')
          ..write('setVideoId: $setVideoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, position, videoId, setVideoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrack &&
          other.playlistId == this.playlistId &&
          other.position == this.position &&
          other.videoId == this.videoId &&
          other.setVideoId == this.setVideoId);
}

class PlaylistTracksCompanion extends UpdateCompanion<PlaylistTrack> {
  final Value<String> playlistId;
  final Value<int> position;
  final Value<String> videoId;
  final Value<String?> setVideoId;
  final Value<int> rowid;
  const PlaylistTracksCompanion({
    this.playlistId = const Value.absent(),
    this.position = const Value.absent(),
    this.videoId = const Value.absent(),
    this.setVideoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksCompanion.insert({
    required String playlistId,
    required int position,
    required String videoId,
    this.setVideoId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        position = Value(position),
        videoId = Value(videoId);
  static Insertable<PlaylistTrack> custom({
    Expression<String>? playlistId,
    Expression<int>? position,
    Expression<String>? videoId,
    Expression<String>? setVideoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (position != null) 'position': position,
      if (videoId != null) 'video_id': videoId,
      if (setVideoId != null) 'set_video_id': setVideoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksCompanion copyWith(
      {Value<String>? playlistId,
      Value<int>? position,
      Value<String>? videoId,
      Value<String?>? setVideoId,
      Value<int>? rowid}) {
    return PlaylistTracksCompanion(
      playlistId: playlistId ?? this.playlistId,
      position: position ?? this.position,
      videoId: videoId ?? this.videoId,
      setVideoId: setVideoId ?? this.setVideoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (setVideoId.present) {
      map['set_video_id'] = Variable<String>(setVideoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('videoId: $videoId, ')
          ..write('setVideoId: $setVideoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, payloadJson, createdAt, attempts, lastError];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(Insertable<PendingOp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOp(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }
}

class PendingOp extends DataClass implements Insertable<PendingOp> {
  final int id;
  final String type;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const PendingOp(
      {required this.id,
      required this.type,
      required this.payloadJson,
      required this.createdAt,
      required this.attempts,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      id: Value(id),
      type: Value(type),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingOp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOp(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingOp copyWith(
          {int? id,
          String? type,
          String? payloadJson,
          DateTime? createdAt,
          int? attempts,
          Value<String?> lastError = const Value.absent()}) =>
      PendingOp(
        id: id ?? this.id,
        type: type ?? this.type,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  PendingOp copyWithCompanion(PendingOpsCompanion data) {
    return PendingOp(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOp(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, payloadJson, createdAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOp &&
          other.id == this.id &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOp> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const PendingOpsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : type = Value(type),
        payloadJson = Value(payloadJson);
  static Insertable<PendingOp> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingOpsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<String?>? lastError}) {
    return PendingOpsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $QueueStateTable extends QueueState
    with TableInfo<$QueueStateTable, QueueStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _trackIdsJsonMeta =
      const VerificationMeta('trackIdsJson');
  @override
  late final GeneratedColumn<String> trackIdsJson = GeneratedColumn<String>(
      'track_ids_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentIndexMeta =
      const VerificationMeta('currentIndex');
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
      'current_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionMsMeta =
      const VerificationMeta('positionMs');
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
      'position_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shuffleOnMeta =
      const VerificationMeta('shuffleOn');
  @override
  late final GeneratedColumn<bool> shuffleOn = GeneratedColumn<bool>(
      'shuffle_on', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("shuffle_on" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _loopModeMeta =
      const VerificationMeta('loopMode');
  @override
  late final GeneratedColumn<String> loopMode = GeneratedColumn<String>(
      'loop_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OFF'));
  static const VerificationMeta _loopCountMeta =
      const VerificationMeta('loopCount');
  @override
  late final GeneratedColumn<int> loopCount = GeneratedColumn<int>(
      'loop_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        trackIdsJson,
        currentIndex,
        positionMs,
        shuffleOn,
        loopMode,
        loopCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_state';
  @override
  VerificationContext validateIntegrity(Insertable<QueueStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_ids_json')) {
      context.handle(
          _trackIdsJsonMeta,
          trackIdsJson.isAcceptableOrUnknown(
              data['track_ids_json']!, _trackIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_trackIdsJsonMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
          _currentIndexMeta,
          currentIndex.isAcceptableOrUnknown(
              data['current_index']!, _currentIndexMeta));
    }
    if (data.containsKey('position_ms')) {
      context.handle(
          _positionMsMeta,
          positionMs.isAcceptableOrUnknown(
              data['position_ms']!, _positionMsMeta));
    }
    if (data.containsKey('shuffle_on')) {
      context.handle(_shuffleOnMeta,
          shuffleOn.isAcceptableOrUnknown(data['shuffle_on']!, _shuffleOnMeta));
    }
    if (data.containsKey('loop_mode')) {
      context.handle(_loopModeMeta,
          loopMode.isAcceptableOrUnknown(data['loop_mode']!, _loopModeMeta));
    }
    if (data.containsKey('loop_count')) {
      context.handle(_loopCountMeta,
          loopCount.isAcceptableOrUnknown(data['loop_count']!, _loopCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueStateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      trackIdsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_ids_json'])!,
      currentIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_index'])!,
      positionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position_ms'])!,
      shuffleOn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}shuffle_on'])!,
      loopMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loop_mode'])!,
      loopCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loop_count'])!,
    );
  }

  @override
  $QueueStateTable createAlias(String alias) {
    return $QueueStateTable(attachedDatabase, alias);
  }
}

class QueueStateData extends DataClass implements Insertable<QueueStateData> {
  final int id;
  final String trackIdsJson;
  final int currentIndex;
  final int positionMs;
  final bool shuffleOn;
  final String loopMode;
  final int loopCount;
  const QueueStateData(
      {required this.id,
      required this.trackIdsJson,
      required this.currentIndex,
      required this.positionMs,
      required this.shuffleOn,
      required this.loopMode,
      required this.loopCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_ids_json'] = Variable<String>(trackIdsJson);
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['shuffle_on'] = Variable<bool>(shuffleOn);
    map['loop_mode'] = Variable<String>(loopMode);
    map['loop_count'] = Variable<int>(loopCount);
    return map;
  }

  QueueStateCompanion toCompanion(bool nullToAbsent) {
    return QueueStateCompanion(
      id: Value(id),
      trackIdsJson: Value(trackIdsJson),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      shuffleOn: Value(shuffleOn),
      loopMode: Value(loopMode),
      loopCount: Value(loopCount),
    );
  }

  factory QueueStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueStateData(
      id: serializer.fromJson<int>(json['id']),
      trackIdsJson: serializer.fromJson<String>(json['trackIdsJson']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      shuffleOn: serializer.fromJson<bool>(json['shuffleOn']),
      loopMode: serializer.fromJson<String>(json['loopMode']),
      loopCount: serializer.fromJson<int>(json['loopCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackIdsJson': serializer.toJson<String>(trackIdsJson),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'shuffleOn': serializer.toJson<bool>(shuffleOn),
      'loopMode': serializer.toJson<String>(loopMode),
      'loopCount': serializer.toJson<int>(loopCount),
    };
  }

  QueueStateData copyWith(
          {int? id,
          String? trackIdsJson,
          int? currentIndex,
          int? positionMs,
          bool? shuffleOn,
          String? loopMode,
          int? loopCount}) =>
      QueueStateData(
        id: id ?? this.id,
        trackIdsJson: trackIdsJson ?? this.trackIdsJson,
        currentIndex: currentIndex ?? this.currentIndex,
        positionMs: positionMs ?? this.positionMs,
        shuffleOn: shuffleOn ?? this.shuffleOn,
        loopMode: loopMode ?? this.loopMode,
        loopCount: loopCount ?? this.loopCount,
      );
  QueueStateData copyWithCompanion(QueueStateCompanion data) {
    return QueueStateData(
      id: data.id.present ? data.id.value : this.id,
      trackIdsJson: data.trackIdsJson.present
          ? data.trackIdsJson.value
          : this.trackIdsJson,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
      shuffleOn: data.shuffleOn.present ? data.shuffleOn.value : this.shuffleOn,
      loopMode: data.loopMode.present ? data.loopMode.value : this.loopMode,
      loopCount: data.loopCount.present ? data.loopCount.value : this.loopCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateData(')
          ..write('id: $id, ')
          ..write('trackIdsJson: $trackIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleOn: $shuffleOn, ')
          ..write('loopMode: $loopMode, ')
          ..write('loopCount: $loopCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackIdsJson, currentIndex, positionMs,
      shuffleOn, loopMode, loopCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueStateData &&
          other.id == this.id &&
          other.trackIdsJson == this.trackIdsJson &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.shuffleOn == this.shuffleOn &&
          other.loopMode == this.loopMode &&
          other.loopCount == this.loopCount);
}

class QueueStateCompanion extends UpdateCompanion<QueueStateData> {
  final Value<int> id;
  final Value<String> trackIdsJson;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<bool> shuffleOn;
  final Value<String> loopMode;
  final Value<int> loopCount;
  const QueueStateCompanion({
    this.id = const Value.absent(),
    this.trackIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleOn = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.loopCount = const Value.absent(),
  });
  QueueStateCompanion.insert({
    this.id = const Value.absent(),
    required String trackIdsJson,
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleOn = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.loopCount = const Value.absent(),
  }) : trackIdsJson = Value(trackIdsJson);
  static Insertable<QueueStateData> custom({
    Expression<int>? id,
    Expression<String>? trackIdsJson,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<bool>? shuffleOn,
    Expression<String>? loopMode,
    Expression<int>? loopCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackIdsJson != null) 'track_ids_json': trackIdsJson,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (shuffleOn != null) 'shuffle_on': shuffleOn,
      if (loopMode != null) 'loop_mode': loopMode,
      if (loopCount != null) 'loop_count': loopCount,
    });
  }

  QueueStateCompanion copyWith(
      {Value<int>? id,
      Value<String>? trackIdsJson,
      Value<int>? currentIndex,
      Value<int>? positionMs,
      Value<bool>? shuffleOn,
      Value<String>? loopMode,
      Value<int>? loopCount}) {
    return QueueStateCompanion(
      id: id ?? this.id,
      trackIdsJson: trackIdsJson ?? this.trackIdsJson,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      shuffleOn: shuffleOn ?? this.shuffleOn,
      loopMode: loopMode ?? this.loopMode,
      loopCount: loopCount ?? this.loopCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackIdsJson.present) {
      map['track_ids_json'] = Variable<String>(trackIdsJson.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (shuffleOn.present) {
      map['shuffle_on'] = Variable<bool>(shuffleOn.value);
    }
    if (loopMode.present) {
      map['loop_mode'] = Variable<String>(loopMode.value);
    }
    if (loopCount.present) {
      map['loop_count'] = Variable<int>(loopCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateCompanion(')
          ..write('id: $id, ')
          ..write('trackIdsJson: $trackIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleOn: $shuffleOn, ')
          ..write('loopMode: $loopMode, ')
          ..write('loopCount: $loopCount')
          ..write(')'))
        .toString();
  }
}

class $CacheIndexTable extends CacheIndex
    with TableInfo<$CacheIndexTable, CacheIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _videoIdMeta =
      const VerificationMeta('videoId');
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
      'video_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itagMeta = const VerificationMeta('itag');
  @override
  late final GeneratedColumn<int> itag = GeneratedColumn<int>(
      'itag', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
      'bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessMeta =
      const VerificationMeta('lastAccess');
  @override
  late final GeneratedColumn<DateTime> lastAccess = GeneratedColumn<DateTime>(
      'last_access', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [videoId, itag, path, bytes, lastAccess];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_index';
  @override
  VerificationContext validateIntegrity(Insertable<CacheIndexData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('video_id')) {
      context.handle(_videoIdMeta,
          videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta));
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('itag')) {
      context.handle(
          _itagMeta, itag.isAcceptableOrUnknown(data['itag']!, _itagMeta));
    } else if (isInserting) {
      context.missing(_itagMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
          _bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('last_access')) {
      context.handle(
          _lastAccessMeta,
          lastAccess.isAcceptableOrUnknown(
              data['last_access']!, _lastAccessMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {videoId, itag};
  @override
  CacheIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheIndexData(
      videoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_id'])!,
      itag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}itag'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      bytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes'])!,
      lastAccess: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_access'])!,
    );
  }

  @override
  $CacheIndexTable createAlias(String alias) {
    return $CacheIndexTable(attachedDatabase, alias);
  }
}

class CacheIndexData extends DataClass implements Insertable<CacheIndexData> {
  final String videoId;
  final int itag;
  final String path;
  final int bytes;
  final DateTime lastAccess;
  const CacheIndexData(
      {required this.videoId,
      required this.itag,
      required this.path,
      required this.bytes,
      required this.lastAccess});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['video_id'] = Variable<String>(videoId);
    map['itag'] = Variable<int>(itag);
    map['path'] = Variable<String>(path);
    map['bytes'] = Variable<int>(bytes);
    map['last_access'] = Variable<DateTime>(lastAccess);
    return map;
  }

  CacheIndexCompanion toCompanion(bool nullToAbsent) {
    return CacheIndexCompanion(
      videoId: Value(videoId),
      itag: Value(itag),
      path: Value(path),
      bytes: Value(bytes),
      lastAccess: Value(lastAccess),
    );
  }

  factory CacheIndexData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheIndexData(
      videoId: serializer.fromJson<String>(json['videoId']),
      itag: serializer.fromJson<int>(json['itag']),
      path: serializer.fromJson<String>(json['path']),
      bytes: serializer.fromJson<int>(json['bytes']),
      lastAccess: serializer.fromJson<DateTime>(json['lastAccess']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'videoId': serializer.toJson<String>(videoId),
      'itag': serializer.toJson<int>(itag),
      'path': serializer.toJson<String>(path),
      'bytes': serializer.toJson<int>(bytes),
      'lastAccess': serializer.toJson<DateTime>(lastAccess),
    };
  }

  CacheIndexData copyWith(
          {String? videoId,
          int? itag,
          String? path,
          int? bytes,
          DateTime? lastAccess}) =>
      CacheIndexData(
        videoId: videoId ?? this.videoId,
        itag: itag ?? this.itag,
        path: path ?? this.path,
        bytes: bytes ?? this.bytes,
        lastAccess: lastAccess ?? this.lastAccess,
      );
  CacheIndexData copyWithCompanion(CacheIndexCompanion data) {
    return CacheIndexData(
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      itag: data.itag.present ? data.itag.value : this.itag,
      path: data.path.present ? data.path.value : this.path,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      lastAccess:
          data.lastAccess.present ? data.lastAccess.value : this.lastAccess,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheIndexData(')
          ..write('videoId: $videoId, ')
          ..write('itag: $itag, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('lastAccess: $lastAccess')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(videoId, itag, path, bytes, lastAccess);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheIndexData &&
          other.videoId == this.videoId &&
          other.itag == this.itag &&
          other.path == this.path &&
          other.bytes == this.bytes &&
          other.lastAccess == this.lastAccess);
}

class CacheIndexCompanion extends UpdateCompanion<CacheIndexData> {
  final Value<String> videoId;
  final Value<int> itag;
  final Value<String> path;
  final Value<int> bytes;
  final Value<DateTime> lastAccess;
  final Value<int> rowid;
  const CacheIndexCompanion({
    this.videoId = const Value.absent(),
    this.itag = const Value.absent(),
    this.path = const Value.absent(),
    this.bytes = const Value.absent(),
    this.lastAccess = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheIndexCompanion.insert({
    required String videoId,
    required int itag,
    required String path,
    required int bytes,
    this.lastAccess = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : videoId = Value(videoId),
        itag = Value(itag),
        path = Value(path),
        bytes = Value(bytes);
  static Insertable<CacheIndexData> custom({
    Expression<String>? videoId,
    Expression<int>? itag,
    Expression<String>? path,
    Expression<int>? bytes,
    Expression<DateTime>? lastAccess,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (videoId != null) 'video_id': videoId,
      if (itag != null) 'itag': itag,
      if (path != null) 'path': path,
      if (bytes != null) 'bytes': bytes,
      if (lastAccess != null) 'last_access': lastAccess,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheIndexCompanion copyWith(
      {Value<String>? videoId,
      Value<int>? itag,
      Value<String>? path,
      Value<int>? bytes,
      Value<DateTime>? lastAccess,
      Value<int>? rowid}) {
    return CacheIndexCompanion(
      videoId: videoId ?? this.videoId,
      itag: itag ?? this.itag,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      lastAccess: lastAccess ?? this.lastAccess,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (itag.present) {
      map['itag'] = Variable<int>(itag.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (lastAccess.present) {
      map['last_access'] = Variable<DateTime>(lastAccess.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheIndexCompanion(')
          ..write('videoId: $videoId, ')
          ..write('itag: $itag, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('lastAccess: $lastAccess, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DataUsageTable extends DataUsage
    with TableInfo<$DataUsageTable, DataUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
      'network', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
      'bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, day, network, kind, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_usage';
  @override
  VerificationContext validateIntegrity(Insertable<DataUsageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
          _bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataUsageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      bytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes'])!,
    );
  }

  @override
  $DataUsageTable createAlias(String alias) {
    return $DataUsageTable(attachedDatabase, alias);
  }
}

class DataUsageData extends DataClass implements Insertable<DataUsageData> {
  final int id;
  final DateTime day;
  final String network;
  final String kind;
  final int bytes;
  const DataUsageData(
      {required this.id,
      required this.day,
      required this.network,
      required this.kind,
      required this.bytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<DateTime>(day);
    map['network'] = Variable<String>(network);
    map['kind'] = Variable<String>(kind);
    map['bytes'] = Variable<int>(bytes);
    return map;
  }

  DataUsageCompanion toCompanion(bool nullToAbsent) {
    return DataUsageCompanion(
      id: Value(id),
      day: Value(day),
      network: Value(network),
      kind: Value(kind),
      bytes: Value(bytes),
    );
  }

  factory DataUsageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataUsageData(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      network: serializer.fromJson<String>(json['network']),
      kind: serializer.fromJson<String>(json['kind']),
      bytes: serializer.fromJson<int>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<DateTime>(day),
      'network': serializer.toJson<String>(network),
      'kind': serializer.toJson<String>(kind),
      'bytes': serializer.toJson<int>(bytes),
    };
  }

  DataUsageData copyWith(
          {int? id,
          DateTime? day,
          String? network,
          String? kind,
          int? bytes}) =>
      DataUsageData(
        id: id ?? this.id,
        day: day ?? this.day,
        network: network ?? this.network,
        kind: kind ?? this.kind,
        bytes: bytes ?? this.bytes,
      );
  DataUsageData copyWithCompanion(DataUsageCompanion data) {
    return DataUsageData(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      network: data.network.present ? data.network.value : this.network,
      kind: data.kind.present ? data.kind.value : this.kind,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataUsageData(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('network: $network, ')
          ..write('kind: $kind, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, network, kind, bytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataUsageData &&
          other.id == this.id &&
          other.day == this.day &&
          other.network == this.network &&
          other.kind == this.kind &&
          other.bytes == this.bytes);
}

class DataUsageCompanion extends UpdateCompanion<DataUsageData> {
  final Value<int> id;
  final Value<DateTime> day;
  final Value<String> network;
  final Value<String> kind;
  final Value<int> bytes;
  const DataUsageCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.network = const Value.absent(),
    this.kind = const Value.absent(),
    this.bytes = const Value.absent(),
  });
  DataUsageCompanion.insert({
    this.id = const Value.absent(),
    required DateTime day,
    required String network,
    required String kind,
    required int bytes,
  })  : day = Value(day),
        network = Value(network),
        kind = Value(kind),
        bytes = Value(bytes);
  static Insertable<DataUsageData> custom({
    Expression<int>? id,
    Expression<DateTime>? day,
    Expression<String>? network,
    Expression<String>? kind,
    Expression<int>? bytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (network != null) 'network': network,
      if (kind != null) 'kind': kind,
      if (bytes != null) 'bytes': bytes,
    });
  }

  DataUsageCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? day,
      Value<String>? network,
      Value<String>? kind,
      Value<int>? bytes}) {
    return DataUsageCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      network: network ?? this.network,
      kind: kind ?? this.kind,
      bytes: bytes ?? this.bytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataUsageCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('network: $network, ')
          ..write('kind: $kind, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [query, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(Insertable<SearchHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  SearchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryData(
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class SearchHistoryData extends DataClass
    implements Insertable<SearchHistoryData> {
  final String query;
  final DateTime at;
  const SearchHistoryData({required this.query, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      query: Value(query),
      at: Value(at),
    );
  }

  factory SearchHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryData(
      query: serializer.fromJson<String>(json['query']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  SearchHistoryData copyWith({String? query, DateTime? at}) =>
      SearchHistoryData(
        query: query ?? this.query,
        at: at ?? this.at,
      );
  SearchHistoryData copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryData(
      query: data.query.present ? data.query.value : this.query,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryData(')
          ..write('query: $query, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryData &&
          other.query == this.query &&
          other.at == this.at);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryData> {
  final Value<String> query;
  final Value<DateTime> at;
  final Value<int> rowid;
  const SearchHistoryCompanion({
    this.query = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    required String query,
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : query = Value(query);
  static Insertable<SearchHistoryData> custom({
    Expression<String>? query,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryCompanion copyWith(
      {Value<String>? query, Value<DateTime>? at, Value<int>? rowid}) {
    return SearchHistoryCompanion(
      query: query ?? this.query,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('query: $query, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistTracksTable playlistTracks = $PlaylistTracksTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  late final $QueueStateTable queueState = $QueueStateTable(this);
  late final $CacheIndexTable cacheIndex = $CacheIndexTable(this);
  late final $DataUsageTable dataUsage = $DataUsageTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        tracks,
        playlists,
        playlistTracks,
        pendingOps,
        queueState,
        cacheIndex,
        dataUsage,
        searchHistory
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String email,
  required String name,
  Value<String?> thumbUrl,
  Value<String?> pageId,
  Value<int> authUser,
  Value<bool> isUsed,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> email,
  Value<String> name,
  Value<String?> thumbUrl,
  Value<String?> pageId,
  Value<int> authUser,
  Value<bool> isUsed,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageId => $composableBuilder(
      column: $table.pageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get authUser => $composableBuilder(
      column: $table.authUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUsed => $composableBuilder(
      column: $table.isUsed, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageId => $composableBuilder(
      column: $table.pageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get authUser => $composableBuilder(
      column: $table.authUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUsed => $composableBuilder(
      column: $table.isUsed, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get thumbUrl =>
      $composableBuilder(column: $table.thumbUrl, builder: (column) => column);

  GeneratedColumn<String> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<int> get authUser =>
      $composableBuilder(column: $table.authUser, builder: (column) => column);

  GeneratedColumn<bool> get isUsed =>
      $composableBuilder(column: $table.isUsed, builder: (column) => column);
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> email = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> thumbUrl = const Value.absent(),
            Value<String?> pageId = const Value.absent(),
            Value<int> authUser = const Value.absent(),
            Value<bool> isUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            email: email,
            name: name,
            thumbUrl: thumbUrl,
            pageId: pageId,
            authUser: authUser,
            isUsed: isUsed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String email,
            required String name,
            Value<String?> thumbUrl = const Value.absent(),
            Value<String?> pageId = const Value.absent(),
            Value<int> authUser = const Value.absent(),
            Value<bool> isUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            email: email,
            name: name,
            thumbUrl: thumbUrl,
            pageId: pageId,
            authUser: authUser,
            isUsed: isUsed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AccountsTable, Account>(table),
                    BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  required String videoId,
  required String title,
  required String artists,
  Value<String?> album,
  Value<int> durationMs,
  Value<String?> thumbUrl,
  Value<bool> isPlayable,
  Value<DateTime?> lastPlayedAt,
  Value<int> rowid,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<String> videoId,
  Value<String> title,
  Value<String> artists,
  Value<String?> album,
  Value<int> durationMs,
  Value<String?> thumbUrl,
  Value<bool> isPlayable,
  Value<DateTime?> lastPlayedAt,
  Value<int> rowid,
});

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artists => $composableBuilder(
      column: $table.artists, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPlayable => $composableBuilder(
      column: $table.isPlayable, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt, builder: (column) => ColumnFilters(column));
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artists => $composableBuilder(
      column: $table.artists, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPlayable => $composableBuilder(
      column: $table.isPlayable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artists =>
      $composableBuilder(column: $table.artists, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get thumbUrl =>
      $composableBuilder(column: $table.thumbUrl, builder: (column) => column);

  GeneratedColumn<bool> get isPlayable => $composableBuilder(
      column: $table.isPlayable, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt, builder: (column) => column);
}

class $$TracksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TracksTable,
    Track,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (Track, BaseReferences<_$AppDatabase, $TracksTable, Track>),
    Track,
    PrefetchHooks Function()> {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> videoId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> artists = const Value.absent(),
            Value<String?> album = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String?> thumbUrl = const Value.absent(),
            Value<bool> isPlayable = const Value.absent(),
            Value<DateTime?> lastPlayedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TracksCompanion(
            videoId: videoId,
            title: title,
            artists: artists,
            album: album,
            durationMs: durationMs,
            thumbUrl: thumbUrl,
            isPlayable: isPlayable,
            lastPlayedAt: lastPlayedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String videoId,
            required String title,
            required String artists,
            Value<String?> album = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String?> thumbUrl = const Value.absent(),
            Value<bool> isPlayable = const Value.absent(),
            Value<DateTime?> lastPlayedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TracksCompanion.insert(
            videoId: videoId,
            title: title,
            artists: artists,
            album: album,
            durationMs: durationMs,
            thumbUrl: thumbUrl,
            isPlayable: isPlayable,
            lastPlayedAt: lastPlayedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TracksTable, Track>(table),
                    BaseReferences<_$AppDatabase, $TracksTable, Track>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TracksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TracksTable,
    Track,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (Track, BaseReferences<_$AppDatabase, $TracksTable, Track>),
    Track,
    PrefetchHooks Function()>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  required String title,
  Value<String?> thumbUrl,
  Value<String?> owner,
  Value<String> source,
  Value<String> privacy,
  Value<int> trackCount,
  Value<DateTime?> syncedAt,
  Value<String?> etag,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> thumbUrl,
  Value<String?> owner,
  Value<String> source,
  Value<String> privacy,
  Value<int> trackCount,
  Value<DateTime?> syncedAt,
  Value<String?> etag,
  Value<int> rowid,
});

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get privacy => $composableBuilder(
      column: $table.privacy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnFilters(column));
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbUrl => $composableBuilder(
      column: $table.thumbUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get privacy => $composableBuilder(
      column: $table.privacy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbUrl =>
      $composableBuilder(column: $table.thumbUrl, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get privacy =>
      $composableBuilder(column: $table.privacy, builder: (column) => column);

  GeneratedColumn<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
    Playlist,
    PrefetchHooks Function()> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> thumbUrl = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> privacy = const Value.absent(),
            Value<int> trackCount = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> etag = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            title: title,
            thumbUrl: thumbUrl,
            owner: owner,
            source: source,
            privacy: privacy,
            trackCount: trackCount,
            syncedAt: syncedAt,
            etag: etag,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> thumbUrl = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> privacy = const Value.absent(),
            Value<int> trackCount = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> etag = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            title: title,
            thumbUrl: thumbUrl,
            owner: owner,
            source: source,
            privacy: privacy,
            trackCount: trackCount,
            syncedAt: syncedAt,
            etag: etag,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PlaylistsTable, Playlist>(table),
                    BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist>),
    Playlist,
    PrefetchHooks Function()>;
typedef $$PlaylistTracksTableCreateCompanionBuilder = PlaylistTracksCompanion
    Function({
  required String playlistId,
  required int position,
  required String videoId,
  Value<String?> setVideoId,
  Value<int> rowid,
});
typedef $$PlaylistTracksTableUpdateCompanionBuilder = PlaylistTracksCompanion
    Function({
  Value<String> playlistId,
  Value<int> position,
  Value<String> videoId,
  Value<String?> setVideoId,
  Value<int> rowid,
});

class $$PlaylistTracksTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setVideoId => $composableBuilder(
      column: $table.setVideoId, builder: (column) => ColumnFilters(column));
}

class $$PlaylistTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setVideoId => $composableBuilder(
      column: $table.setVideoId, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get setVideoId => $composableBuilder(
      column: $table.setVideoId, builder: (column) => column);
}

class $$PlaylistTracksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistTracksTable,
    PlaylistTrack,
    $$PlaylistTracksTableFilterComposer,
    $$PlaylistTracksTableOrderingComposer,
    $$PlaylistTracksTableAnnotationComposer,
    $$PlaylistTracksTableCreateCompanionBuilder,
    $$PlaylistTracksTableUpdateCompanionBuilder,
    (
      PlaylistTrack,
      BaseReferences<_$AppDatabase, $PlaylistTracksTable, PlaylistTrack>
    ),
    PlaylistTrack,
    PrefetchHooks Function()> {
  $$PlaylistTracksTableTableManager(
      _$AppDatabase db, $PlaylistTracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> playlistId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> videoId = const Value.absent(),
            Value<String?> setVideoId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTracksCompanion(
            playlistId: playlistId,
            position: position,
            videoId: videoId,
            setVideoId: setVideoId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String playlistId,
            required int position,
            required String videoId,
            Value<String?> setVideoId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTracksCompanion.insert(
            playlistId: playlistId,
            position: position,
            videoId: videoId,
            setVideoId: setVideoId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PlaylistTracksTable, PlaylistTrack>(table),
                    BaseReferences<_$AppDatabase, $PlaylistTracksTable,
                        PlaylistTrack>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistTracksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistTracksTable,
    PlaylistTrack,
    $$PlaylistTracksTableFilterComposer,
    $$PlaylistTracksTableOrderingComposer,
    $$PlaylistTracksTableAnnotationComposer,
    $$PlaylistTracksTableCreateCompanionBuilder,
    $$PlaylistTracksTableUpdateCompanionBuilder,
    (
      PlaylistTrack,
      BaseReferences<_$AppDatabase, $PlaylistTracksTable, PlaylistTrack>
    ),
    PlaylistTrack,
    PrefetchHooks Function()>;
typedef $$PendingOpsTableCreateCompanionBuilder = PendingOpsCompanion Function({
  Value<int> id,
  required String type,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});
typedef $$PendingOpsTableUpdateCompanionBuilder = PendingOpsCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});

class $$PendingOpsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingOpsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingOpsTable,
    PendingOp,
    $$PendingOpsTableFilterComposer,
    $$PendingOpsTableOrderingComposer,
    $$PendingOpsTableAnnotationComposer,
    $$PendingOpsTableCreateCompanionBuilder,
    $$PendingOpsTableUpdateCompanionBuilder,
    (PendingOp, BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOp>),
    PendingOp,
    PrefetchHooks Function()> {
  $$PendingOpsTableTableManager(_$AppDatabase db, $PendingOpsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              PendingOpsCompanion(
            id: id,
            type: type,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String payloadJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              PendingOpsCompanion.insert(
            id: id,
            type: type,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PendingOpsTable, PendingOp>(table),
                    BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOp>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingOpsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingOpsTable,
    PendingOp,
    $$PendingOpsTableFilterComposer,
    $$PendingOpsTableOrderingComposer,
    $$PendingOpsTableAnnotationComposer,
    $$PendingOpsTableCreateCompanionBuilder,
    $$PendingOpsTableUpdateCompanionBuilder,
    (PendingOp, BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOp>),
    PendingOp,
    PrefetchHooks Function()>;
typedef $$QueueStateTableCreateCompanionBuilder = QueueStateCompanion Function({
  Value<int> id,
  required String trackIdsJson,
  Value<int> currentIndex,
  Value<int> positionMs,
  Value<bool> shuffleOn,
  Value<String> loopMode,
  Value<int> loopCount,
});
typedef $$QueueStateTableUpdateCompanionBuilder = QueueStateCompanion Function({
  Value<int> id,
  Value<String> trackIdsJson,
  Value<int> currentIndex,
  Value<int> positionMs,
  Value<bool> shuffleOn,
  Value<String> loopMode,
  Value<int> loopCount,
});

class $$QueueStateTableFilterComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackIdsJson => $composableBuilder(
      column: $table.trackIdsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentIndex => $composableBuilder(
      column: $table.currentIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get shuffleOn => $composableBuilder(
      column: $table.shuffleOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loopMode => $composableBuilder(
      column: $table.loopMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get loopCount => $composableBuilder(
      column: $table.loopCount, builder: (column) => ColumnFilters(column));
}

class $$QueueStateTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackIdsJson => $composableBuilder(
      column: $table.trackIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentIndex => $composableBuilder(
      column: $table.currentIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get shuffleOn => $composableBuilder(
      column: $table.shuffleOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loopMode => $composableBuilder(
      column: $table.loopMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get loopCount => $composableBuilder(
      column: $table.loopCount, builder: (column) => ColumnOrderings(column));
}

class $$QueueStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackIdsJson => $composableBuilder(
      column: $table.trackIdsJson, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
      column: $table.currentIndex, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => column);

  GeneratedColumn<bool> get shuffleOn =>
      $composableBuilder(column: $table.shuffleOn, builder: (column) => column);

  GeneratedColumn<String> get loopMode =>
      $composableBuilder(column: $table.loopMode, builder: (column) => column);

  GeneratedColumn<int> get loopCount =>
      $composableBuilder(column: $table.loopCount, builder: (column) => column);
}

class $$QueueStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueueStateTable,
    QueueStateData,
    $$QueueStateTableFilterComposer,
    $$QueueStateTableOrderingComposer,
    $$QueueStateTableAnnotationComposer,
    $$QueueStateTableCreateCompanionBuilder,
    $$QueueStateTableUpdateCompanionBuilder,
    (
      QueueStateData,
      BaseReferences<_$AppDatabase, $QueueStateTable, QueueStateData>
    ),
    QueueStateData,
    PrefetchHooks Function()> {
  $$QueueStateTableTableManager(_$AppDatabase db, $QueueStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> trackIdsJson = const Value.absent(),
            Value<int> currentIndex = const Value.absent(),
            Value<int> positionMs = const Value.absent(),
            Value<bool> shuffleOn = const Value.absent(),
            Value<String> loopMode = const Value.absent(),
            Value<int> loopCount = const Value.absent(),
          }) =>
              QueueStateCompanion(
            id: id,
            trackIdsJson: trackIdsJson,
            currentIndex: currentIndex,
            positionMs: positionMs,
            shuffleOn: shuffleOn,
            loopMode: loopMode,
            loopCount: loopCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String trackIdsJson,
            Value<int> currentIndex = const Value.absent(),
            Value<int> positionMs = const Value.absent(),
            Value<bool> shuffleOn = const Value.absent(),
            Value<String> loopMode = const Value.absent(),
            Value<int> loopCount = const Value.absent(),
          }) =>
              QueueStateCompanion.insert(
            id: id,
            trackIdsJson: trackIdsJson,
            currentIndex: currentIndex,
            positionMs: positionMs,
            shuffleOn: shuffleOn,
            loopMode: loopMode,
            loopCount: loopCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QueueStateTable, QueueStateData>(table),
                    BaseReferences<_$AppDatabase, $QueueStateTable,
                        QueueStateData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueueStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueueStateTable,
    QueueStateData,
    $$QueueStateTableFilterComposer,
    $$QueueStateTableOrderingComposer,
    $$QueueStateTableAnnotationComposer,
    $$QueueStateTableCreateCompanionBuilder,
    $$QueueStateTableUpdateCompanionBuilder,
    (
      QueueStateData,
      BaseReferences<_$AppDatabase, $QueueStateTable, QueueStateData>
    ),
    QueueStateData,
    PrefetchHooks Function()>;
typedef $$CacheIndexTableCreateCompanionBuilder = CacheIndexCompanion Function({
  required String videoId,
  required int itag,
  required String path,
  required int bytes,
  Value<DateTime> lastAccess,
  Value<int> rowid,
});
typedef $$CacheIndexTableUpdateCompanionBuilder = CacheIndexCompanion Function({
  Value<String> videoId,
  Value<int> itag,
  Value<String> path,
  Value<int> bytes,
  Value<DateTime> lastAccess,
  Value<int> rowid,
});

class $$CacheIndexTableFilterComposer
    extends Composer<_$AppDatabase, $CacheIndexTable> {
  $$CacheIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itag => $composableBuilder(
      column: $table.itag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccess => $composableBuilder(
      column: $table.lastAccess, builder: (column) => ColumnFilters(column));
}

class $$CacheIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheIndexTable> {
  $$CacheIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itag => $composableBuilder(
      column: $table.itag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccess => $composableBuilder(
      column: $table.lastAccess, builder: (column) => ColumnOrderings(column));
}

class $$CacheIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheIndexTable> {
  $$CacheIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<int> get itag =>
      $composableBuilder(column: $table.itag, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccess => $composableBuilder(
      column: $table.lastAccess, builder: (column) => column);
}

class $$CacheIndexTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CacheIndexTable,
    CacheIndexData,
    $$CacheIndexTableFilterComposer,
    $$CacheIndexTableOrderingComposer,
    $$CacheIndexTableAnnotationComposer,
    $$CacheIndexTableCreateCompanionBuilder,
    $$CacheIndexTableUpdateCompanionBuilder,
    (
      CacheIndexData,
      BaseReferences<_$AppDatabase, $CacheIndexTable, CacheIndexData>
    ),
    CacheIndexData,
    PrefetchHooks Function()> {
  $$CacheIndexTableTableManager(_$AppDatabase db, $CacheIndexTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> videoId = const Value.absent(),
            Value<int> itag = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> bytes = const Value.absent(),
            Value<DateTime> lastAccess = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheIndexCompanion(
            videoId: videoId,
            itag: itag,
            path: path,
            bytes: bytes,
            lastAccess: lastAccess,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String videoId,
            required int itag,
            required String path,
            required int bytes,
            Value<DateTime> lastAccess = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheIndexCompanion.insert(
            videoId: videoId,
            itag: itag,
            path: path,
            bytes: bytes,
            lastAccess: lastAccess,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CacheIndexTable, CacheIndexData>(table),
                    BaseReferences<_$AppDatabase, $CacheIndexTable,
                        CacheIndexData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheIndexTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CacheIndexTable,
    CacheIndexData,
    $$CacheIndexTableFilterComposer,
    $$CacheIndexTableOrderingComposer,
    $$CacheIndexTableAnnotationComposer,
    $$CacheIndexTableCreateCompanionBuilder,
    $$CacheIndexTableUpdateCompanionBuilder,
    (
      CacheIndexData,
      BaseReferences<_$AppDatabase, $CacheIndexTable, CacheIndexData>
    ),
    CacheIndexData,
    PrefetchHooks Function()>;
typedef $$DataUsageTableCreateCompanionBuilder = DataUsageCompanion Function({
  Value<int> id,
  required DateTime day,
  required String network,
  required String kind,
  required int bytes,
});
typedef $$DataUsageTableUpdateCompanionBuilder = DataUsageCompanion Function({
  Value<int> id,
  Value<DateTime> day,
  Value<String> network,
  Value<String> kind,
  Value<int> bytes,
});

class $$DataUsageTableFilterComposer
    extends Composer<_$AppDatabase, $DataUsageTable> {
  $$DataUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnFilters(column));
}

class $$DataUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $DataUsageTable> {
  $$DataUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnOrderings(column));
}

class $$DataUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataUsageTable> {
  $$DataUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$DataUsageTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DataUsageTable,
    DataUsageData,
    $$DataUsageTableFilterComposer,
    $$DataUsageTableOrderingComposer,
    $$DataUsageTableAnnotationComposer,
    $$DataUsageTableCreateCompanionBuilder,
    $$DataUsageTableUpdateCompanionBuilder,
    (
      DataUsageData,
      BaseReferences<_$AppDatabase, $DataUsageTable, DataUsageData>
    ),
    DataUsageData,
    PrefetchHooks Function()> {
  $$DataUsageTableTableManager(_$AppDatabase db, $DataUsageTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> day = const Value.absent(),
            Value<String> network = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> bytes = const Value.absent(),
          }) =>
              DataUsageCompanion(
            id: id,
            day: day,
            network: network,
            kind: kind,
            bytes: bytes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime day,
            required String network,
            required String kind,
            required int bytes,
          }) =>
              DataUsageCompanion.insert(
            id: id,
            day: day,
            network: network,
            kind: kind,
            bytes: bytes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DataUsageTable, DataUsageData>(table),
                    BaseReferences<_$AppDatabase, $DataUsageTable,
                        DataUsageData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DataUsageTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DataUsageTable,
    DataUsageData,
    $$DataUsageTableFilterComposer,
    $$DataUsageTableOrderingComposer,
    $$DataUsageTableAnnotationComposer,
    $$DataUsageTableCreateCompanionBuilder,
    $$DataUsageTableUpdateCompanionBuilder,
    (
      DataUsageData,
      BaseReferences<_$AppDatabase, $DataUsageTable, DataUsageData>
    ),
    DataUsageData,
    PrefetchHooks Function()>;
typedef $$SearchHistoryTableCreateCompanionBuilder = SearchHistoryCompanion
    Function({
  required String query,
  Value<DateTime> at,
  Value<int> rowid,
});
typedef $$SearchHistoryTableUpdateCompanionBuilder = SearchHistoryCompanion
    Function({
  Value<String> query,
  Value<DateTime> at,
  Value<int> rowid,
});

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$SearchHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchHistoryTable,
    SearchHistoryData,
    $$SearchHistoryTableFilterComposer,
    $$SearchHistoryTableOrderingComposer,
    $$SearchHistoryTableAnnotationComposer,
    $$SearchHistoryTableCreateCompanionBuilder,
    $$SearchHistoryTableUpdateCompanionBuilder,
    (
      SearchHistoryData,
      BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryData>
    ),
    SearchHistoryData,
    PrefetchHooks Function()> {
  $$SearchHistoryTableTableManager(_$AppDatabase db, $SearchHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> query = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchHistoryCompanion(
            query: query,
            at: at,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String query,
            Value<DateTime> at = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchHistoryCompanion.insert(
            query: query,
            at: at,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SearchHistoryTable, SearchHistoryData>(table),
                    BaseReferences<_$AppDatabase, $SearchHistoryTable,
                        SearchHistoryData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchHistoryTable,
    SearchHistoryData,
    $$SearchHistoryTableFilterComposer,
    $$SearchHistoryTableOrderingComposer,
    $$SearchHistoryTableAnnotationComposer,
    $$SearchHistoryTableCreateCompanionBuilder,
    $$SearchHistoryTableUpdateCompanionBuilder,
    (
      SearchHistoryData,
      BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryData>
    ),
    SearchHistoryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistTracksTableTableManager get playlistTracks =>
      $$PlaylistTracksTableTableManager(_db, _db.playlistTracks);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
  $$QueueStateTableTableManager get queueState =>
      $$QueueStateTableTableManager(_db, _db.queueState);
  $$CacheIndexTableTableManager get cacheIndex =>
      $$CacheIndexTableTableManager(_db, _db.cacheIndex);
  $$DataUsageTableTableManager get dataUsage =>
      $$DataUsageTableTableManager(_db, _db.dataUsage);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
}
