import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenAccessKey = 'token';
  static const String _tokenRefreshKey = 'token_refresh';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenAccessKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenAccessKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _tokenAccessKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _tokenRefreshKey);
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> saveUserId(int id) async {
    await _storage.write(key: _userIdKey, value: id.toString());
  }

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
