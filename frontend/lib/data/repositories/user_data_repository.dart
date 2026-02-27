import 'package:frontend/data/services/secure_storage_service.dart';

class UserDataRepository {
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<Map<String, String?>> loadUserData() async {
    final sessionId = await _secureStorage.read('session-id');
    final userId = await _secureStorage.read('id');
    final username = await _secureStorage.read('username');
    final country = await _secureStorage.read('country');
    final city = await _secureStorage.read('city');
    final email = await _secureStorage.read('email');
    final password = await _secureStorage.read('password');
    final administrator = await _secureStorage.read('administrator');

    return {
      'session-id': sessionId,
      'id': userId,
      'username': username,
      'country': country,
      'city': city,
      'email': email,
      'password': password,
      'administrator': administrator,
    };
  }
}
