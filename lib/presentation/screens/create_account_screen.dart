import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/presentation/screens/home_screen.dart';
import 'package:edulearn/presentation/widget/app_text_field.dart';
import 'package:edulearn/core/responsive.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController      = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _studentIdController = TextEditingController();
  final _majorController     = TextEditingController();
  final _schoolController    = TextEditingController();
  final _yearController      = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _majorController.dispose();
    _schoolController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // for validaion
  String? _validateInputs() {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) return "Please enter your full name.";
    if (email.isEmpty) return "Please enter your email address.";
    if (!_isValidEmail(email)) return "Please enter a valid email address.";
    if (password.isEmpty) return "Please enter a password.";
    if (password.length < 6) return "Password must be at least 6 characters.";

    return null; // hata yok
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _handleRegister() async {
    final error = _validateInputs();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().register(
      fullName:  _nameController.text.trim(),
      email:     _emailController.text.trim(),
      password:  _passwordController.text,
      studentId: _studentIdController.text.isEmpty ? null : _studentIdController.text.trim(),
      major:     _majorController.text.isEmpty     ? null : _majorController.text.trim(),
      school:    _schoolController.text.isEmpty    ? null : _schoolController.text.trim(),
      year:      _yearController.text.isEmpty      ? null : _yearController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        _showError(
          context.read<AuthProvider>().errorMessage ?? "Registration failed.",
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
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text  = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: color.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.pagePadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: Responsive.spacing(context) * 0.625),

                  // for minimal logo section
                  Center(
                    child: Container(
                      width:  Responsive.buttonHeight(context) * 1.25,
                      height: Responsive.buttonHeight(context) * 1.25,
                      decoration: BoxDecoration(
                        color: color.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.person_add_rounded,
                          color: color.primary,
                          size: Responsive.icon(context) * 1.45),
                    ),
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  Text("Create Account",
                      textAlign: TextAlign.center,
                      style: text.headlineMedium?.copyWith(
                          color: color.onSurface, fontWeight: FontWeight.bold)),

                  SizedBox(height: Responsive.spacing(context) * 0.375),

                  Text("Start your learning journey",
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                          color: color.onSurface.withValues(alpha: 0.5))),

                  SizedBox(height: Responsive.sectionSpacing(context) * 1.25),

                  // for required fields
                  _label("Full Name *", color, text),
                  AppTextField(
                    controller:      _nameController,
                    hint:            "Full Name",
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  _label("Email *", color, text),
                  AppTextField(
                    controller:      _emailController,
                    hint:            "Email Address",
                    keyboardType:    TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  _label("Password *", color, text),
                  AppTextField(
                    controller:      _passwordController,
                    hint:            "Password (min. 6 characters)",
                    obscureText:     _obscurePassword,
                    textInputAction: TextInputAction.next,
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

                  SizedBox(height: Responsive.sectionSpacing(context) * 1.25),

                  // optional divider part
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
                      child: Text("OPTIONAL INFO",
                          style: text.labelSmall?.copyWith(
                              color: color.primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                    ),
                    Expanded(
                      child: Divider(
                        color: color.primary.withValues(alpha: 0.3),
                        thickness: 1,
                      ),
                    ),
                  ]),

                  SizedBox(height: Responsive.spacing(context) * 1.25),

                  // in optional fields
                  _label("Student ID", color, text),
                  AppTextField(
                    controller:      _studentIdController,
                    hint:            "Student ID",
                    isNumber:        true,               // for numerical
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  _label("Major", color, text),
                  AppTextField(
                    controller:      _majorController,
                    hint:            "Major",
                    keyboardType:    TextInputType.name,
                    lettersOnly:     true,              // for just letters
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  _label("School", color, text),
                  AppTextField(
                    controller:      _schoolController,
                    hint:            "School",
                    keyboardType:    TextInputType.name,
                    lettersOnly:     true,              // only letter we can write, not all data
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  _label("Current Year", color, text),
                  AppTextField(
                    controller:      _yearController,
                    hint:            "e.g. 1, 2, 3, 4",
                    isNumber:        true,
                    maxLength:       1,                  // for just one digit to write your grade
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

                  // for register button i did
                  SizedBox(
                    height: Responsive.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primary,
                        foregroundColor: color.onPrimary,
                        disabledBackgroundColor:
                        color.primary.withValues(alpha: 0.5),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: color.onPrimary, strokeWidth: 2.5),
                      )
                          : Text("Create Account",
                          style: text.titleSmall?.copyWith(
                              color: color.onPrimary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  SizedBox(
                    height: Responsive.buttonHeight(context),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color.primary,
                        side: BorderSide(color: color.primary, width: 1.5),
                      ),
                      child: Text("Back to Sign In",
                          style: text.titleSmall?.copyWith(
                              color: color.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(height: Responsive.sectionSpacing(context) * 2),
                ],
              ),
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