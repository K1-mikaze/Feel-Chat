import 'package:flutter/material.dart';
import 'package:frontend/bloc/user_data/user_data_bloc.dart';
import 'package:frontend/bloc/user_data/user_data_state.dart';
import 'package:frontend/configurations/routes/app_routes.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/admin_service.dart';
import 'package:frontend/views/widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  String? _userId;
  String? _sessionId;
  List<dynamic>? _users;
  bool _isLoading = false;
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
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_userId == null || _sessionId == null) return;
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getUsers(_sessionId!, _userId!);
      if (mounted) {
        setState(() {
          _users = users ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                ? _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildUserList()
                : const Center(child: Text('Loading...')),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_users == null || _users!.isEmpty) {
      return const Center(child: Text('No Users Available'));
    }
    return ListView.builder(
      itemCount: _users!.length,
      itemBuilder: (context, index) {
        final user = _users![index] as Map<String, dynamic>;
        return Dismissible(
          key: ValueKey(user['id']),
          direction: DismissDirection.startToEnd,
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(user);
          },
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.updateUserAdminScreen,
                  arguments: user,
                );
              },
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(
                  (user['username'] ?? '')[0].toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user['username'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${user['country'] ?? ''} ${user['city'] ?? ''}'),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(Map<String, dynamic> user) async {
    final username = user['username'] ?? '';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && _userId != null && _sessionId != null) {
      setState(() => _isLoading = true);
      try {
        final deleted = await _adminService.deleteUser(
          _sessionId!,
          _userId!,
          user['id'].toString(),
        );
        if (deleted) {
          await _loadUsers();
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete user')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting user: $e')),
          );
        }
      }
    }
    return false;
  }
}
