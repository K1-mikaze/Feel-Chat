import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/feelchat_appbar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeelChatAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Country'),
              onChanged: (value) {},
              items: const [],
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select City'),
              onChanged: (value) {},
              items: const [],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement apply changes
              },
              child: const Text('Apply Changes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement change email
              },
              child: const Text('Change Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement change username
              },
              child: const Text('Change Username'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // TODO: Implement delete account
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
