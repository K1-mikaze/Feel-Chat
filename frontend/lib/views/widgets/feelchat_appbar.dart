import 'package:flutter/material.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/configurations/routes/app_routes.dart';

AppBar feelchatAppbar(
  BuildContext context, {
  bool isAdmin = false,
  String title = '',
}) {
  return AppBar(
    backgroundColor: Colors.purple,
    title: Text(
      title.isEmpty ? 'Feel Chat' : title,
      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
    ),
    actions: [
      PopupMenuButton<String>(
        iconColor: Colors.white,
        onSelected: (value) {
          if (value == 'logout') {
            _showLogoutDialog(context);
          } else if (value == 'account') {
            Navigator.pushNamed(context, AppRoutes.accountScreen);
          } else if (value == 'admin') {
            Navigator.pushNamed(context, AppRoutes.adminScreen);
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            const PopupMenuItem(value: 'account', child: Text('Account')),
          ];
          if (isAdmin) {
            items.add(
              const PopupMenuItem(value: 'admin', child: Text('Admin')),
            );
          }
          items.add(
            const PopupMenuItem(value: 'logout', child: Text('Log Out')),
          );
          return items;
        },
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

  if (result == true && context.mounted) {
    final secureStorage = SecureStorageService();
    final userId = await secureStorage.read('id');
    final sessionId = await secureStorage.read('session-id');

    if (userId != null && sessionId != null && context.mounted) {
      final userService = UserService();
      final logoutSuccess = await userService.logOut(userId, sessionId);

      if (logoutSuccess && context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      }
    }
  }
}
