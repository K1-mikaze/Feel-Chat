import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/services/secure_storage_service.dart';

class UserService {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/users';
  final http.Client _client = http.Client();
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<int> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 202) {
      final sessionData = jsonDecode(response.body) as Map<String, dynamic>;
      for (final entry in sessionData.entries) {
        await _secureStorage.write(entry.key, entry.value.toString());
      }
      final sessionId = response.headers['session-id'];
      if (sessionId != null) {
        await _secureStorage.write('session-id', sessionId);
      }
      return 1;
    }
    if (response.statusCode == 401 || response.statusCode == 404) return 0;
    return 3;
  }

  Future<List<dynamic>?> getCurrentChats(
    String userId,
    String sessionId,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/getcurrentchats'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return null;
  }

  Future<List<dynamic>?> getSuggestionChats(
    String userId,
    String sessionId,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/getsuggestionschats'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return null;
  }

  Future<bool> logOut(String userId, String sessionId) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/logout'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      _secureStorage.deleteAll();
      return true;
    }
    return false;
  }

  Future<bool> updateInformation({
    required String sessionId,
    required String userId,
    required String country,
    required String city,
    required String mood,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/updateinformation'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({
        'user_id': userId,
        'country': country,
        'city': city,
        'mood': mood,
      }),
    );

    return response.statusCode == 201;
  }

  Future<bool> getUser(String sessionId, String userId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/getuser'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body) as Map<String, dynamic>;
      for (final entry in userData.entries) {
        await _secureStorage.write(entry.key, entry.value.toString());
      }
      return true;
    }
    return false;
  }

  Future<int> updateUsername({
    required String sessionId,
    required String userId,
    required String newUsername,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/updateusername'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId, 'username': newUsername}),
    );

    if (response.statusCode == 201) return 1;
    if (response.statusCode == 404) return 0;
    if (response.statusCode == 409) return 2;
    if (response.statusCode == 401) return 3;
    return 4;
  }

  Future<int> updatePassword({
    required String sessionId,
    required String userId,
    required String newPassword,
    required String oldPassword,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/updatepassword'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({
        'user_id': userId,
        'new_password': newPassword,
        'old_password': oldPassword,
      }),
    );

    if (response.statusCode == 201) return 1;
    if (response.statusCode == 404) return 0;
    if (response.statusCode == 409) return 2;
    if (response.statusCode == 401) return 3;
    return 4;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String country,
    required String city,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
        'country': country,
        'city': city,
      }),
    );

    return response.statusCode == 201;
  }

  Future<bool> sendEmail({
    required String sessionId,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/sendemail'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    return response.statusCode == 200;
  }

  Future<int> verifyEmail({
    required String sessionId,
    required String userId,
    required int code,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/verifyemail'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId, 'code': code}),
    );

    if (response.statusCode == 200) return 1;
    if (response.statusCode == 404) return 2;
    return 0;
  }

  Future<bool> delete({
    required String sessionId,
    required String userId,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/delete'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    return response.statusCode == 200;
  }

  Future<bool> sendEmail2(String email) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/sendemail2'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response.statusCode == 200;
  }

  Future<bool> forgotPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/forgotpassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'password': password}),
    );
    return response.statusCode == 201;
  }
}
