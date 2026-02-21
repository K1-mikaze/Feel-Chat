import 'package:flutter/material.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/configurations/routes/app_routes.dart';

AppBar FeelChatAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.purple,
    title: const Text(
      'Feel chat',
      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
    ),
    actions: [
      PopupMenuButton<String>(
        iconColor: Colors.white,
        onSelected: (value) {
          if (value == 'settings') {
            // TODO: Navigate to settings
          } else if (value == 'logout') {
            _showLogoutDialog(context);
          } else if (value == 'account') {
            Navigator.pushNamed(context, AppRoutes.accountScreen);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'account', child: Text('Account')),
          PopupMenuItem(value: 'settings', child: Text('Settings')),
          PopupMenuItem(value: 'logout', child: Text('Log Out')),
        ],
      ),
    ],
  );
}

Future<void> _showLogoutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out'),
      content: const Text('Are you sure do you want to Log Out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );

  if (result == true) {
    final secureStorage = SecureStorageService();
    final userId = await secureStorage.read('id');
    final sessionId = await secureStorage.read('session-id');

    if (userId != null && sessionId != null) {
      final logoutSuccess = await UserService().logOut(userId, sessionId);

      if (logoutSuccess) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      }
    }
  }
}
