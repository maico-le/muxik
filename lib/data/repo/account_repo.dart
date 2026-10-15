import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../yt/yt_client.dart';
import '../yt/yt_models.dart';

/// Secure token & session storage
class AuthStorage {
  final FlutterSecureStorage _storage;

  const AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _activeEmailKey = 'musical_active_email';
  static const _cookiePrefix = 'musical_cookie_';

  Future<void> saveCookie(String email, String cookie) async {
    await _storage.write(key: '$_cookiePrefix$email', value: cookie);
  }

  Future<String?> getCookie(String email) async {
    return await _storage.read(key: '$_cookiePrefix$email');
  }

  Future<void> deleteCookie(String email) async {
    await _storage.delete(key: '$_cookiePrefix$email');
  }

  Future<void> setActiveEmail(String? email) async {
    if (email == null) {
      await _storage.delete(key: _activeEmailKey);
    } else {
      await _storage.write(key: _activeEmailKey, value: email);
    }
  }

  Future<String?> getActiveEmail() async {
    return await _storage.read(key: _activeEmailKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// Repository managing Google/YouTube session authentication and account switching
class AccountRepo {
  final AppDatabase db;
  final YtClient ytClient;
  final AuthStorage authStorage;

  AccountRepo({
    required this.db,
    required this.ytClient,
    AuthStorage? authStorage,
  }) : authStorage = authStorage ?? const AuthStorage();

  /// Initialize and load saved active account into YtClient
  Future<YtAccount?> loadActiveAccount() async {
    final activeEmail = await authStorage.getActiveEmail();
    if (activeEmail == null) return null;

    final cookie = await authStorage.getCookie(activeEmail);
    if (cookie == null || cookie.isEmpty) return null;

    final account = await (db.select(db.accounts)
          ..where((a) => a.email.equals(activeEmail)))
        .getSingleOrNull();

    if (account != null) {
      ytClient.cookie = cookie;
      ytClient.authUser = account.authUser;
      ytClient.pageId = account.pageId;

      return YtAccount(
        email: account.email,
        name: account.name,
        thumbUrl: account.thumbUrl,
        pageId: account.pageId,
        authUser: account.authUser,
        isUsed: true,
      );
    }
    return null;
  }

  /// Authenticate with a new cookie (from WebView or Dev Input Sheet).
  /// Verifies SAPISID, tests getAccountSwitcherEndpoint, saves to DB & secure storage.
  /// If fails, rolls back to previous active credentials.
  Future<List<YtAccount>> authenticateWithCookie(String cookie) async {
    // 1. Verify required security cookies
    final sapisid = YtClient.extractCookie(cookie, 'SAPISID') ??
        YtClient.extractCookie(cookie, '__Secure-3PAPISID');
    if (sapisid == null || sapisid.isEmpty) {
      throw const FormatException('Missing SAPISID or __Secure-3PAPISID in cookie');
    }

    // Backup previous state for rollback
    final prevCookie = ytClient.cookie;
    final prevAuthUser = ytClient.authUser;
    final prevPageId = ytClient.pageId;

    try {
      // Temporarily set new cookie to verify
      ytClient.cookie = cookie;
      ytClient.authUser = 0;
      ytClient.pageId = null;

      // 2. Query account switcher endpoint
      final accounts = await ytClient.getAccountSwitcher();
      if (accounts.isEmpty) {
        throw Exception('No accounts returned from getAccountSwitcherEndpoint');
      }

      // Pick the currently selected account or first
      final selectedAccount = accounts.firstWhere(
        (a) => a.isUsed,
        orElse: () => accounts.first,
      );

      // 3. Save cookie securely
      await authStorage.saveCookie(selectedAccount.email, cookie);
      await authStorage.setActiveEmail(selectedAccount.email);

      // 4. Save accounts to DB
      await db.transaction(() async {
        // Mark all existing accounts as not used
        await (db.update(db.accounts)).write(
          const AccountsCompanion(isUsed: Value(false)),
        );

        for (final acc in accounts) {
          final isCurrent = acc.email == selectedAccount.email;
          await db.into(db.accounts).insertOnConflictUpdate(
                AccountsCompanion(
                  email: Value(acc.email),
                  name: Value(acc.name),
                  thumbUrl: Value(acc.thumbUrl),
                  pageId: Value(acc.pageId),
                  authUser: Value(acc.authUser),
                  isUsed: Value(isCurrent),
                ),
              );
        }
      });

      ytClient.authUser = selectedAccount.authUser;
      ytClient.pageId = selectedAccount.pageId;

      return accounts;
    } catch (e) {
      // Rollback on failure
      ytClient.cookie = prevCookie;
      ytClient.authUser = prevAuthUser;
      ytClient.pageId = prevPageId;
      rethrow;
    }
  }

  /// Switch active account (e.g. brand channel or secondary account)
  Future<void> switchAccount(String email) async {
    final account = await (db.select(db.accounts)
          ..where((a) => a.email.equals(email)))
        .getSingleOrNull();

    if (account == null) {
      throw Exception('Account $email not found in database');
    }

    final cookie = await authStorage.getCookie(email);
    if (cookie == null || cookie.isEmpty) {
      throw Exception('Cookie for $email not found in secure storage');
    }

    await db.transaction(() async {
      await (db.update(db.accounts)).write(
        const AccountsCompanion(isUsed: Value(false)),
      );
      await (db.update(db.accounts)..where((a) => a.email.equals(email))).write(
        const AccountsCompanion(isUsed: Value(true)),
      );
    });

    await authStorage.setActiveEmail(email);

    ytClient.cookie = cookie;
    ytClient.authUser = account.authUser;
    ytClient.pageId = account.pageId;
  }

  /// Log out and wipe secure tokens & account records
  Future<void> logout() async {
    final activeEmail = await authStorage.getActiveEmail();
    if (activeEmail != null) {
      await authStorage.deleteCookie(activeEmail);
    }
    await authStorage.setActiveEmail(null);

    await (db.delete(db.accounts)).go();

    ytClient.cookie = null;
    ytClient.authUser = 0;
    ytClient.pageId = null;
  }

  /// Watch all stored accounts
  Stream<List<Account>> watchAccounts() {
    return (db.select(db.accounts)
          ..orderBy([(a) => OrderingTerm.desc(a.isUsed)]))
        .watch();
  }
}
