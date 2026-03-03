import 'package:flutter/material.dart';
import 'package:frontend/views/screens.dart';

class AppRoutes {
  static const initialRoute = loginScreen;

  static const String loginScreen = 'loginscreen';
  static const String menuScreen = 'menuscreen';
  static const String accountScreen = 'accountscreen';
  static const String signinScreen = 'signinscreen';
  static const String verifyAccountScreen = 'verifyaccountscreen';
  static const String forgotPasswordScreen = 'forgotpasswordscreen';
  static const String adminScreen = 'adminscreen';
  static const String updateUserAdminScreen = 'updateuseradminscreen';

  static Map<String, Widget Function(BuildContext)> routes = {
    loginScreen: (context) => const LoginScreen(),
    menuScreen: (context) => const MenuScreen(),
    accountScreen: (context) => const AccountScreen(),
    signinScreen: (context) => const SignUpScreen(),
    verifyAccountScreen: (context) => const VerifyAccountScreen(),
    forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
    adminScreen: (context) => const AdminScreen(),
    updateUserAdminScreen: (context) =>
        UpdateUserAdminScreen(user: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
  };
}
