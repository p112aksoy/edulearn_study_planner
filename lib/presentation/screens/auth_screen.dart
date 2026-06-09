import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/presentation/screens/home_screen.dart';
import 'package:edulearn/presentation/screens/create_account_screen.dart';
import 'package:edulearn/presentation/screens/forgot_password_screen.dart';
import 'package:edulearn/presentation/widget/app_text_field.dart';
import 'package:edulearn/core/responsive.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // this is important part which is validation section
  String? _validateInputs() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return "Please enter your email address.";
    if (!_isValidEmail(email)) return "Please enter a valid email address.";
    if (password.isEmpty) return "Please enter your password.";

    return null;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _handleLogin() async {
    final error = _validateInputs();
    if (error != null) {
      _showError(error);
      return;
    }

    // useing AuthProvider.isLoading
    final success = await context.read<AuthProvider>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showError(
          context.read<AuthProvider>().errorMessage ?? "Login failed.",
        );
      }
    }
  }

  void _showError(String message) {
    final color = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: color.onPrimary)),
      backgroundColor: color.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final color    = theme.colorScheme;
    final text     = theme.textTheme;
    // we are listening AuthProvider.isLoading directly
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: Responsive.height(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Responsive.height(context) * 0.08),

                // minimal logo section
                Center(
                  child: Container(
                    width:  Responsive.buttonHeight(context) * 1.28,
                    height: Responsive.buttonHeight(context) * 1.28,
                    decoration: BoxDecoration(
                      color: color.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.school_rounded,
                        color: color.primary,
                        size: Responsive.icon(context) * 1.6),
                  ),
                ),

                SizedBox(height: Responsive.spacing(context) * 1.25),

                Text("EduLearn",
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),

                SizedBox(height: Responsive.spacing(context) * 0.375),

                Text("Sign In",
                    textAlign: TextAlign.center,
                    style: text.headlineMedium?.copyWith(
                        color: color.onSurface, fontWeight: FontWeight.bold)),

                SizedBox(height: Responsive.spacing(context) * 0.5),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context) * 1.5,
                  ),
                  child: Text("Welcome back! Please enter your details.",
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                          color: color.onSurface.withValues(alpha: 0.5))),
                ),

                SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

                // for email part
                _label("Email", color, text),
                AppTextField(
                  controller:      _emailController,
                  hint:            "Email Address",
                  keyboardType:    TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: Responsive.spacing(context) * 1.25),

                // this is for password part
                _label("Password", color, text),
                AppTextField(
                  controller:      _passwordController,
                  hint:            "Password",
                  obscureText:     _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: color.primary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: Text("Forgot Password?",
                        style: text.bodySmall?.copyWith(
                            color: color.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600)),
                  ),
                ),

                SizedBox(height: Responsive.spacing(context) * 1.25),

                // for loggin button part
                SizedBox(
                  height: Responsive.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.primary,
                      foregroundColor: color.onPrimary,
                      disabledBackgroundColor:
                      color.primary.withValues(alpha: 0.5),
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: color.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text("Continue",
                        style: text.titleSmall?.copyWith(
                            color: color.onPrimary,
                            fontWeight: FontWeight.bold)),
                  ),
                ),

                SizedBox(height: Responsive.spacing(context) * 1.125),

                // this is divider section
                Row(children: [
                  Expanded(
                    child: Divider(
                      color: color.primary.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context) * 0.75,
                    ),
                    child: Text("or",
                        style: text.bodySmall?.copyWith(
                            color: color.onSurface.withValues(alpha: 0.4))),
                  ),
                  Expanded(
                    child: Divider(
                      color: color.primary.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ]),

                SizedBox(height: Responsive.spacing(context) * 1.125),

                // for create account part
                SizedBox(
                  height: Responsive.buttonHeight(context),
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color.primary,
                      side: BorderSide(color: color.primary, width: 1.5),
                    ),
                    child: Text("Create Account",
                        style: text.titleSmall?.copyWith(
                            color: color.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                ),

                SizedBox(height: Responsive.sectionSpacing(context) * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String label, ColorScheme color, TextTheme text) {
    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        bottom: Responsive.spacing(context) * 0.5,
      ),
      child: Text(label,
          style: text.bodySmall?.copyWith(
              color: color.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600)),
    );
  }
}