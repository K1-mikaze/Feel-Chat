import 'package:flutter/material.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/utils/validators/validations.dart';
import 'package:frontend/configurations/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');
    final verified = await secureStorage.read('verified');

    if (sessionId != null && userId != null && mounted && verified == 'true') {
      Navigator.pushReplacementNamed(context, AppRoutes.menuScreen);
    }else if (sessionId != null && userId != null && mounted && verified == 'false'){
      Navigator.pushReplacementNamed(context, AppRoutes.verifyAccountScreen);
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userService = UserService();
      final result = await userService.login(
        _emailController.text,
        _passwordController.text,
      );
      setState(() => _isLoading = false);
      if (!mounted) return;

      switch (result) {
        case 1:
          final secureStorageService = SecureStorageService();
          final id = await secureStorageService.read('id');
          final sessionId = await secureStorageService.read('session-id');
          final verified = await secureStorageService.read('verified');
          if (id != null && sessionId != null  && verified == 'false' ) {
            await userService.sendEmail(sessionId: sessionId, userId: id);
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verifyAccountScreen,
              );
            }
          }
          if(mounted && verified == 'true') {
            Navigator.pushReplacementNamed(context, AppRoutes.menuScreen);
          }
          break;
        case 0:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not found')));
          break;
        case 3:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Feel Chat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signinScreen);
                },
                child: const Text("You don't have an account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
