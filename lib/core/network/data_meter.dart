import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../data/db/app_database.dart';
import 'network_policy.dart';

class DailyUsageSummary {
  final DateTime day;
  final int cellBytes;
  final int wifiBytes;
  final int audioBytes;
  final int imageBytes;
  final int apiBytes;

  DailyUsageSummary({
    required this.day,
    required this.cellBytes,
    required this.wifiBytes,
    required this.audioBytes,
    required this.imageBytes,
    required this.apiBytes,
  });

  int get totalBytes => cellBytes + wifiBytes;
}

/// Central data meter service tracking real byte transfers across Audio, Image, and API
class DataMeter extends ChangeNotifier {
  final AppDatabase _db;
  final NetworkPolicy _networkPolicy;

  DataMeter({
    required AppDatabase db,
    required NetworkPolicy networkPolicy,
  })  : _db = db,
        _networkPolicy = networkPolicy {
    _refreshCurrentMonthCellular();
  }

  /// Normalize a date to midnight (00:00:00)
  static DateTime normalizeDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Record byte transfer
  Future<void> recordUsage({
    required String kind, // 'audio' | 'image' | 'api'
    required int bytes,
    String? network, // 'wifi' | 'cell'
  }) async {
    if (bytes <= 0) return;

    final net = network ?? (_networkPolicy.isCellular ? 'cell' : 'wifi');
    final today = normalizeDay(DateTime.now());

    // Check if entry exists for (today, net, kind)
    final existing = await (_db.select(_db.dataUsage)
          ..where((u) =>
              u.day.equals(today) &
              u.network.equals(net) &
              u.kind.equals(kind)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.dataUsage)..where((u) => u.id.equals(existing.id))).write(
        DataUsageCompanion(
          bytes: Value(existing.bytes + bytes),
        ),
      );
    } else {
      await _db.into(_db.dataUsage).insert(
            DataUsageCompanion.insert(
              day: today,
              network: net,
              kind: kind,
              bytes: bytes,
            ),
          );
    }

    if (net == 'cell') {
      await _refreshCurrentMonthCellular();
    }

    notifyListeners();
  }

  /// Refresh month cellular usage and notify network policy
  Future<int> _refreshCurrentMonthCellular() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final usages = await (_db.select(_db.dataUsage)
          ..where((u) =>
              u.network.equals('cell') &
              u.day.isBiggerOrEqualValue(firstDayOfMonth) &
              u.day.isSmallerOrEqualValue(lastDayOfMonth)))
        .get();

    final total = usages.fold<int>(0, (sum, u) => sum + u.bytes);
    _networkPolicy.updateCurrentMonthCellularBytes(total);
    return total;
  }

  /// Get usage for a specific day
  Future<int> getDayUsage(DateTime date, {String? network, String? kind}) async {
    final day = normalizeDay(date);
    var query = _db.select(_db.dataUsage)..where((u) => u.day.equals(day));

    if (network != null) {
      query = query..where((u) => u.network.equals(network));
    }
    if (kind != null) {
      query = query..where((u) => u.kind.equals(kind));
    }

    final rows = await query.get();
    return rows.fold<int>(0, (sum, u) => sum + u.bytes);
  }

  /// Get month usage (sum)
  Future<int> getMonthUsage(DateTime date, {String? network, String? kind}) async {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    var query = _db.select(_db.dataUsage)
      ..where((u) =>
          u.day.isBiggerOrEqualValue(firstDay) &
          u.day.isSmallerOrEqualValue(lastDay));

    if (network != null) {
      query = query..where((u) => u.network.equals(network));
    }
    if (kind != null) {
      query = query..where((u) => u.kind.equals(kind));
    }

    final rows = await query.get();
    return rows.fold<int>(0, (sum, u) => sum + u.bytes);
  }

  /// Get daily history for the last [days] days
  Future<List<DailyUsageSummary>> getDailyHistory({int days = 7}) async {
    final now = DateTime.now();
    final summaries = <DailyUsageSummary>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = normalizeDay(now.subtract(Duration(days: i)));
      final rows = await (_db.select(_db.dataUsage)..where((u) => u.day.equals(day))).get();

      int cell = 0;
      int wifi = 0;
      int audio = 0;
      int image = 0;
      int api = 0;

      for (final r in rows) {
        if (r.network == 'cell') cell += r.bytes;
        if (r.network == 'wifi') wifi += r.bytes;
        if (r.kind == 'audio') audio += r.bytes;
        if (r.kind == 'image') image += r.bytes;
        if (r.kind == 'api') api += r.bytes;
      }

      summaries.add(DailyUsageSummary(
        day: day,
        cellBytes: cell,
        wifiBytes: wifi,
        audioBytes: audio,
        imageBytes: image,
        apiBytes: api,
      ));
    }

    return summaries;
  }
}
