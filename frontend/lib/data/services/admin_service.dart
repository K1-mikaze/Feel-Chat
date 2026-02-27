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
      return jsonDecode(response.body) as List<dynamic>;
    }
    return null;
  }
}
