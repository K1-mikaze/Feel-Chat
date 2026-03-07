import 'package:flutter/material.dart';
import 'package:frontend/bloc/user_data/user_data_bloc.dart';
import 'package:frontend/bloc/user_data/user_data_state.dart';
import 'package:frontend/configurations/routes/app_routes.dart';
import 'package:frontend/data/services/chat_service.dart';
import 'package:frontend/data/services/chat_ws_service.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/views/widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  String? _userId;
  String? _sessionId;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>?> _chatsFuture;
  late Future<List<dynamic>?> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final secureStorage = SecureStorageService();
    _userId = await secureStorage.read('id');
    _sessionId = await secureStorage.read('session-id');

    if (_sessionId != null) {
      ChatWsService.instance.connect(_sessionId!);
      _chatsFuture = ChatService().getChats(_sessionId!);
      _suggestionsFuture = UserService().getSuggestionChats(
        _userId!,
        _sessionId!,
      );
    }

    setState(() {});
  }

  Future<void> _navigateToChat(Map<String, dynamic> chat) async {
    final contactId = chat['id'] as String?;
    final username = chat['username'] as String?;

    if (contactId == null ||
        username == null ||
        _userId == null ||
        _sessionId == null) {
      return;
    }

    final chatId = await ChatService().getChatId(
      sessionId: _sessionId!,
      userId: _userId!,
      contactId: contactId,
    );

    if (chatId != null && mounted) {
      await Navigator.pushNamed(
        context,
        AppRoutes.chatScreen,
        arguments: {
          'chatId': chatId,
          'userId': _userId,
          'contactId': contactId,
          'username': username,
        },
      );
      _loadUserData();
    }
  }

  Future<bool> _deleteChat(Map<String, dynamic> chat) async {
    final chatId = chat['chatId'] as String?;
    final username = chat['otherParticipant']['username'] as String?;

    if (chatId == null || _sessionId == null) return false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete the chat with $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await ChatService().deleteChat(
        sessionId: _sessionId!,
        chatId: chatId,
      );

      if (deleted) {
        _loadUserData();
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ChatWsService.instance.connectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == false && _sessionId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection unavailable'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
        return Scaffold(
          appBar: feelchatAppbar(
            context,
            isAdmin:
                UserDataBloc.instance.state is UserDataLoaded &&
                (UserDataBloc.instance.state as UserDataLoaded).administrator ==
                    'true',
          ),
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
              Text(
                "Suggested chats",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: _userId != null && _sessionId != null
                    ? FutureBuilder(
                        future: _suggestionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                              return GestureDetector(
                                onTap: () => _navigateToChat(chat),
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${chat['username'][0].toString().toUpperCase()}${chat['username'].toString().substring(1).toLowerCase()}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${chat['country']}, ${chat['city']}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Mood: ${chat['mood'][0].toString().toUpperCase()}${chat['mood'].toString().substring(1).toLowerCase()}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : const Center(child: Text('Loading...')),
              ),
              Text(
                "Current chats",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                flex: 3,
                child: _userId != null && _sessionId != null
                    ? RefreshIndicator(
                        onRefresh: () async {
                          _loadUserData();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 200,
                            child: FutureBuilder(
                              future: _chatsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final chats = snapshot.data as List<dynamic>;
                                if (chats.isEmpty) {
                                  return const Center(
                                    child: Text('Not Chats Available'),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: chats.length,
                                  itemBuilder: (context, index) {
                                    final chat =
                                        chats[index] as Map<String, dynamic>;
                                    return Dismissible(
                                      key: ValueKey(chat['chatId']),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (direction) async =>
                                          await _deleteChat(chat),
                                      background: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                          border: chat['latestMessage'] != null &&
                                                  chat['latestMessage']
                                                          ['senderId'] ==
                                                      chat['otherParticipant']
                                                          ['id']
                                              ? Border.all(
                                                  color: Colors.deepPurple,
                                                  width: 2)
                                              : null,
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.purple,
                                            child: Text(
                                              (chat['otherParticipant']
                                                          ['username'] ??
                                                      '')[0]
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "${chat['otherParticipant']['username'][0].toString().toUpperCase()}${chat['otherParticipant']['username'].toString().substring(1)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          trailing: Text(
                                            "${chat['otherParticipant']['mood'][0]}${chat['otherParticipant']['mood'].toString().substring(1).toLowerCase()}",
                                          ),
                                          subtitle: Text(
                                            "${chat['latestMessage']['senderId'] != chat['otherParticipant']['id'] ? 'You: ' : ''} ${chat['latestMessage']['content']}",
                                          ),
                                          onTap: () async {
                                            await Navigator.pushNamed(
                                              context,
                                              AppRoutes.chatScreen,
                                              arguments: {
                                                'chatId': chat['chatId'],
                                                'userId': _userId,
                                                'contactId':
                                                    chat['otherParticipant']
                                                        ['id'],
                                                'username':
                                                    chat['otherParticipant']
                                                        ['username'],
                                              },
                                            );
                                            _loadUserData();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : const Center(child: Text('Loading...')),
              ),
            ],
          ),
        );
      },
    );
  }
}
