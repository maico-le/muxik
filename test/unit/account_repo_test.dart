import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:musical/data/db/app_database.dart';
import 'package:musical/data/yt/yt_client.dart';
import 'package:musical/data/repo/account_repo.dart';

class MockDio extends Mock implements Dio {}
class MockAuthStorage extends Mock implements AuthStorage {}

void main() {
  group('Milestone 2 - AccountRepo & Authentication Tests', () {
    late AppDatabase db;
    late MockDio mockDio;
    late YtClient ytClient;
    late MockAuthStorage mockAuthStorage;
    late AccountRepo accountRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      mockDio = MockDio();
      ytClient = YtClient(dio: mockDio);
      mockAuthStorage = MockAuthStorage();
      accountRepo = AccountRepo(
        db: db,
        ytClient: ytClient,
        authStorage: mockAuthStorage,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('authenticateWithCookie throws FormatException when SAPISID is missing', () async {
      const invalidCookie = 'VISITOR_INFO1_LIVE=abc; PREF=tz=UTC';

      expect(
        () => accountRepo.authenticateWithCookie(invalidCookie),
        throwsA(isA<FormatException>()),
      );
    });

    test('authenticateWithCookie saves accounts, sets active, and handles rollback on failure', () async {
      const validCookie =
          'SAPISID=test_sapisid_value_123; HSID=test; SSID=test; SID=test';
      const fixtureData = ''')]}'
{
  "actions": [
    {
      "getMultiPageMenuAction": {
        "menu": {
          "multiPageMenuRenderer": {
            "sections": [
              {
                "accountSectionListRenderer": {
                  "contents": [
                    {
                      "accountItemRenderer": {
                        "accountName": {"runs": [{"text": "Pixel User"}]},
                        "accountEmail": {"runs": [{"text": "pixel.user@example.com"}]},
                        "accountPhoto": {"thumbnails": [{"url": "https://example.com/thumb.jpg", "width": 64, "height": 64}]},
                        "isSelected": true,
                        "serviceEndpoint": {
                          "selectActiveIdentityEndpoint": {
                            "supportedTokens": [{"pageId": "100023456789012345678"}]
                          }
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
  ]
}''';

      when(() => mockAuthStorage.saveCookie(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAuthStorage.setActiveEmail(any()))
          .thenAnswer((_) async {});
      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response<String>(
            data: fixtureData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await accountRepo.authenticateWithCookie(validCookie);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.name, equals('Pixel User'));

      // Check DB persistence
      final savedAccounts = await db.select(db.accounts).get();
      expect(savedAccounts.length, equals(1));
      expect(savedAccounts.first.email, equals('pixel.user@example.com'));
      expect(savedAccounts.first.isUsed, isTrue);

      verify(() => mockAuthStorage.saveCookie('pixel.user@example.com', validCookie)).called(1);
      verify(() => mockAuthStorage.setActiveEmail('pixel.user@example.com')).called(1);
    });

    test('authenticateWithCookie rolls back credentials when getAccountSwitcher throws', () async {
      const validCookie = 'SAPISID=invalid_session_expired;';

      // Setup initial client state
      ytClient.cookie = 'old_valid_cookie';
      ytClient.authUser = 0;
      ytClient.pageId = null;

      when(() => mockDio.get<String>(
            any(),
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(statusCode: 401, requestOptions: RequestOptions(path: '')),
        ),
      );

      // Expect failure and verify rollback after await
      await expectLater(
        () => accountRepo.authenticateWithCookie(validCookie),
        throwsA(isA<DioException>()),
      );

      // Verify rollback: ytClient restored to old_valid_cookie
      expect(ytClient.cookie, equals('old_valid_cookie'));
    });

    test('switchAccount updates active account in DB and updates YtClient state', () async {
      // Seed accounts into memory DB
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              email: 'primary@example.com',
              name: 'Primary User',
              isUsed: const Value(true),
            ),
          );
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              email: 'brand@example.com',
              name: 'Brand Channel',
              pageId: const Value('brand_page_id'),
              isUsed: const Value(false),
            ),
          );

      when(() => mockAuthStorage.getCookie('brand@example.com'))
          .thenAnswer((_) async => 'brand_cookie_string');
      when(() => mockAuthStorage.setActiveEmail('brand@example.com'))
          .thenAnswer((_) async {});

      // Act: switch to brand account
      await accountRepo.switchAccount('brand@example.com');

      // Assert
      final brandAcc = await (db.select(db.accounts)
            ..where((a) => a.email.equals('brand@example.com')))
          .getSingle();
      final primaryAcc = await (db.select(db.accounts)
            ..where((a) => a.email.equals('primary@example.com')))
          .getSingle();

      expect(brandAcc.isUsed, isTrue);
      expect(primaryAcc.isUsed, isFalse);
      expect(ytClient.cookie, equals('brand_cookie_string'));
      expect(ytClient.pageId, equals('brand_page_id'));
    });

    test('logout deletes active cookie, clears database and resets YtClient', () async {
      when(() => mockAuthStorage.getActiveEmail())
          .thenAnswer((_) async => 'user@example.com');
      when(() => mockAuthStorage.deleteCookie('user@example.com'))
          .thenAnswer((_) async {});
      when(() => mockAuthStorage.setActiveEmail(null))
          .thenAnswer((_) async {});

      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              email: 'user@example.com',
              name: 'User',
              isUsed: const Value(true),
            ),
          );

      ytClient.cookie = 'some_cookie';

      // Act
      await accountRepo.logout();

      // Assert
      final accounts = await db.select(db.accounts).get();
      expect(accounts, isEmpty);
      expect(ytClient.cookie, isNull);
      verify(() => mockAuthStorage.deleteCookie('user@example.com')).called(1);
    });
  });
}
