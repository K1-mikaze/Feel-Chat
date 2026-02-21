import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/services/secure_storage_service.dart';

class UserService {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/users';
  final http.Client _client = http.Client();
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<bool> login(String email, String password) async {
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
      return true;
    }
    return false;
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
      body: jsonEncode({'userId': userId}),
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
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      _secureStorage.delete("id");
      _secureStorage.delete("session-id");
      return true;
    }
    return false;
  }
}
