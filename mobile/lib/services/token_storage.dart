import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'voxa_jwt_token';

  Future<void> salvarToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> recuperarToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> removerToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
