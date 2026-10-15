import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_policy.dart';
import '../network/data_meter.dart';
import '../network/data_meter_interceptor.dart';
import '../../audio/audio_cache_manager.dart';
import 'auth_providers.dart';

/// NetworkPolicy Provider
final networkPolicyProvider = ChangeNotifierProvider<NetworkPolicy>((ref) {
  final policy = NetworkPolicy();
  ref.onDispose(() => policy.dispose());
  return policy;
});

/// DataMeter Provider
final dataMeterProvider = ChangeNotifierProvider<DataMeter>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final networkPolicy = ref.watch(networkPolicyProvider);

  final meter = DataMeter(db: db, networkPolicy: networkPolicy);

  // Attach DataMeterInterceptor to YtClient's Dio
  final ytClient = ref.watch(ytClientProvider);
  final hasInterceptor = ytClient.dio.interceptors.any((i) => i is DataMeterInterceptor);
  if (!hasInterceptor) {
    ytClient.dio.interceptors.add(DataMeterInterceptor(dataMeter: meter));
  }

  ref.onDispose(() => meter.dispose());
  return meter;
});

/// AudioCacheManager Provider
final audioCacheManagerProvider = ChangeNotifierProvider<AudioCacheManager>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final manager = AudioCacheManager(db: db);
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Daily Usage History Stream/Future Provider
final dailyUsageHistoryProvider = FutureProvider<List<DailyUsageSummary>>((ref) async {
  final meter = ref.watch(dataMeterProvider);
  return meter.getDailyHistory(days: 7);
});

/// Total Cache Size Provider
final totalCacheSizeBytesProvider = FutureProvider<int>((ref) async {
  final cacheManager = ref.watch(audioCacheManagerProvider);
  return cacheManager.getTotalCacheBytes();
});
