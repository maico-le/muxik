import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repo/sync_repo.dart';
import 'auth_providers.dart';
import 'network_providers.dart';

/// SyncRepo Provider
final syncRepoProvider = Provider<SyncRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final ytClient = ref.watch(ytClientProvider);
  final networkPolicy = ref.watch(networkPolicyProvider);

  return SyncRepo(
    db: db,
    ytClient: ytClient,
    networkPolicy: networkPolicy,
  );
});

/// Pending operations count stream provider for sync badge
final pendingOpsCountStreamProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(syncRepoProvider);
  return repo.watchPendingOpsCount();
});
