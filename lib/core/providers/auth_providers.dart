import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/app_database.dart';
import '../../data/yt/yt_client.dart';
import '../../data/repo/account_repo.dart';
import '../../data/yt/fake_yt_repository.dart';

/// AppDatabase Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// InnerTube YtClient Provider
final ytClientProvider = Provider<YtClient>((ref) {
  return YtClient();
});

/// FakeYtRepository Provider (for dev / test mode)
final fakeYtRepositoryProvider = Provider<FakeYtRepository>((ref) {
  return FakeYtRepository();
});

/// AccountRepo Provider
final accountRepoProvider = Provider<AccountRepo>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final ytClient = ref.watch(ytClientProvider);
  return AccountRepo(db: db, ytClient: ytClient);
});

/// Current active account state
final activeAccountProvider = FutureProvider((ref) async {
  final repo = ref.watch(accountRepoProvider);
  return await repo.loadActiveAccount();
});

/// Stream of all saved accounts
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepoProvider);
  return repo.watchAccounts();
});
