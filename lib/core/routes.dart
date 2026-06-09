import 'package:flutter/material.dart';
import 'package:edulearn/presentation/screens/auth_screen.dart';
import 'package:edulearn/presentation/screens/home_screen.dart';
import 'package:edulearn/presentation/screens/create_account_screen.dart';
import 'package:edulearn/presentation/screens/forgot_password_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AuthScreen(),
    '/home': (context) => const HomeScreen(),
    '/create-account': (context) => const CreateAccountScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
  };
}