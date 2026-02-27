import 'package:flutter/material.dart';
import 'package:frontend/bloc/user_data/user_data_bloc.dart';
import 'package:frontend/bloc/user_data/user_data_state.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/admin_service.dart';
import 'package:frontend/views/widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AdminService adminService = AdminService();

    return Scaffold(
      appBar: feelchatAppbar(
        context,
        isAdmin:
            UserDataBloc.instance.state is UserDataLoaded &&
            (UserDataBloc.instance.state as UserDataLoaded).administrator ==
                'true',
        title: "Administrator Panel",
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
          Expanded(
            child: _userId != null && _sessionId != null
                ? FutureBuilder(
                    future: adminService.getUsers(_sessionId!, _userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data;
                      if (users == null) {
                        return const Center(child: Text('No Users Available'));
                      }
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index] as Map<String, dynamic>;
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
                                  (user['username'] ?? '')[0]
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                user['username'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${user['country'] ?? ''} ${user['city'] ?? ''}',
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
