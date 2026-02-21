import 'package:flutter/material.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/views/widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? _userId;
  String? _sessionId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final secureStorage = SecureStorageService();
    _userId = await secureStorage.read('id');
    _sessionId = await secureStorage.read('session-id');
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeelChatAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _userId != null && _sessionId != null
                ? FutureBuilder(
                    future: UserService().getSuggestionChats(
                      _userId!,
                      _sessionId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final chats = snapshot.data;
                      if (chats == null) {
                        return const Center(
                          child: Text('Not suggestions Available'),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index] as Map<String, dynamic>;
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  chat['username'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(chat['country'] ?? ''),
                                Text(chat['city'] ?? ''),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('Loading...')),
          ),
          Expanded(
            flex: 2,
            child: _userId != null && _sessionId != null
                ? FutureBuilder(
                    future: UserService().getCurrentChats(
                      _userId!,
                      _sessionId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final chats = snapshot.data;
                      if (chats == null) {
                        return const Center(child: Text('Not Chats Available'));
                      }
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index] as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Text(
                                  (chat['username'] ?? '')[0]
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                chat['username'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('Loading...')),
          ),
        ],
      ),
    );
  }
}

