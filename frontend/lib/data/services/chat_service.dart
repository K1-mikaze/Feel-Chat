import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://10.0.2.2:8080/api/v1/chats';
  final http.Client _client = http.Client();

  Future<String?> findChat({
    required String sessionId,
    required String userId,
    required String contactId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/findchat'),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'user_id': userId, 'contact_id': contactId}),
    );

    if (response.statusCode == 200) {
      return response.body.replaceAll('"', '');
    }
    return null;
  }

  Future<String?> getChatId({
    required String sessionId,
    required String userId,
    required String contactId,
  }) async {
    return findChat(sessionId: sessionId, userId: userId, contactId: contactId);
  }

  Future<List<dynamic>?> getChats(String sessionId) async {
    final response = await _client.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return null;
  }

  Future<bool> deleteChat({
    required String sessionId,
    required String chatId,
  }) async {
    final response = await _client.delete(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'session-id': sessionId},
      body: jsonEncode({'chat_id': chatId}),
    );

    return response.statusCode == 200;
  }
}
