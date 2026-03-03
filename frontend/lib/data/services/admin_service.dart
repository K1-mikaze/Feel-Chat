import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/admin';
  final http.Client _client = http.Client();

  Future<List<dynamic>?> getUsers(String sessionId, String userId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      return jsonDecode(response.body) as List<dynamic>;
    }
    return null;
  }

  Future<bool> deleteUser(
    String sessionId,
    String userId,
    String deleteId,
  ) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId, 'delete_id': deleteId}),
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> updateUser(
    String sessionId,
    String userId,
    Map<String, dynamic> user,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({
        'user_id': userId,
        'id': user['id'],
        'username': user['username'],
        'password': user['password'].toString().trim().isEmpty
            ? ''
            : user['password'],
        'city': user['city'],
        'country': user['country'],
        'verified': user['verified'],
        'deleted': user['deleted'],
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
