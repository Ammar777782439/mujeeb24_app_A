import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Only the rotating refresh cookie is persisted. Access tokens remain in
/// process memory and are always minted anew on a successful cold start.
///
/// Never use SharedPreferences/plain files for these credentials.
abstract class RefreshCookieStore {
  Future<String?> read();
  Future<void> write(String cookie);
  Future<void> delete();
}

class EncryptedRefreshCookieStore implements RefreshCookieStore {
  static const _key = 'mujeeb24.refresh_cookie.v1';
  final FlutterSecureStorage _storage;

  EncryptedRefreshCookieStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String cookie) => _storage.write(
        key: _key,
        value: cookie,
      );

  @override
  Future<void> delete() => _storage.delete(key: _key);
}
