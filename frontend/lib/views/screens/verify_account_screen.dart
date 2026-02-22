import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/configurations/routes/app_routes.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final codeText = _codeController.text.trim();
    if (codeText.isEmpty || codeText.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final secureStorage = SecureStorageService();
    final userId = await secureStorage.read('id');
    final sessionId = await secureStorage.read('session-id');

    if (userId == null || sessionId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: Missing session')));
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      }
      return;
    }

    final code = int.parse(codeText);
    final userService = UserService();
    final result = await userService.verifyEmail(
      sessionId: sessionId,
      userId: userId,
      code: code,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    switch (result) {
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.menuScreen);
        break;
      case 2:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wrong code')));
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    }
  }

  Future<void> _handleResendCode() async {
    final secureStorage = SecureStorageService();
    final userId = await secureStorage.read('id');
    final sessionId = await secureStorage.read('session-id');

    if (userId == null || sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: Missing session')));
      }
      return;
    }

    final userService = UserService();
    final success = await userService.sendEmail(
      sessionId: sessionId,
      userId: userId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code Sent')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Verify your Account',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit code sent to your email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: TextFormField(
                controller: _codeController,
                maxLength: 6,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _handleResendCode,
              child: const Text('Send the code again'),
            ),
          ],
        ),
      ),
    );
  }
}
