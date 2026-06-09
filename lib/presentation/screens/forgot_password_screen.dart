import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/presentation/widget/app_text_field.dart';
import 'package:edulearn/core/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool    _isLoading   = false;
  String? _newPassword;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email.");
      return;
    }
    setState(() => _isLoading = true);
    final newPassword = await context
        .read<AuthProvider>()
        .resetPassword(_emailController.text);
    if (mounted) {
      setState(() {
        _isLoading   = false;
        _newPassword = newPassword;
      });
      if (newPassword == null) {
        _showError("No account found with this email.");
      }
    }
  }

  void _showError(String message) {
    final color = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: TextStyle(color: color.onPrimary)),
      backgroundColor: color.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context))),
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
        leading: Padding(
          padding: EdgeInsets.only(left: Responsive.spacing(context) * 0.375),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: color.primary,
                size: Responsive.smallIcon(context)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.pagePadding(context)),
              child: _newPassword != null
                  ? _buildSuccessView(color, text)
                  : _buildFormView(color, text),
            ),
          ),
        ),
      ),
    );
  }

  // form view part
  Widget _buildFormView(ColorScheme color, TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.sectionSpacing(context) * 1.25),

        Icon(Icons.lock_reset_rounded,
            color: color.primary,
            size: Responsive.icon(context) * 3.6),

        SizedBox(height: Responsive.sectionSpacing(context)),

        Text("Forgot Password?",
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(
                color: color.onSurface, fontWeight: FontWeight.bold)),

        SizedBox(height: Responsive.spacing(context) * 0.75),

        Text("Enter your email and we'll generate a new password for you.",
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.5), height: 1.5)),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),

        Text("Email",
            style: text.bodySmall?.copyWith(
                color: color.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600)),

        SizedBox(height: Responsive.spacing(context) * 0.5),


        AppTextField(
          controller:  _emailController,
          hint:        "Email Address",
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),

        SizedBox(
          height: Responsive.buttonHeight(context),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              disabledBackgroundColor: color.primary.withValues(alpha: 0.5),
            ),
            child: _isLoading
                ? SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: color.onPrimary, strokeWidth: 2.5))
                : Text("Get New Password",
                style: text.titleSmall?.copyWith(
                    color: color.onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),
      ],
    );
  }

  // for success view, to get new password to enter again if you forget
  Widget _buildSuccessView(ColorScheme color, TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

        Icon(Icons.check_circle_outline_rounded,
            color: color.primary,
            size: Responsive.icon(context) * 4),

        SizedBox(height: Responsive.sectionSpacing(context)),

        Text("New Password Ready!",
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(
                color: color.onSurface, fontWeight: FontWeight.bold)),

        SizedBox(height: Responsive.spacing(context) * 0.75),

        Text("Your new password is shown below.\nUse it to sign in.",
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.5), height: 1.5)),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),

        Container(
          padding: EdgeInsets.all(Responsive.sectionSpacing(context)),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
            border: Border.all(
                color: color.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text("Your New Password",
                  style: text.bodySmall?.copyWith(
                      color: color.onSurface.withValues(alpha: 0.5))),

              SizedBox(height: Responsive.spacing(context) * 0.75),

              SelectableText(
                _newPassword!,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),

              SizedBox(height: Responsive.spacing(context)),

              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _newPassword!));
                  final color = Theme.of(context).colorScheme;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Password copied!",
                        style: TextStyle(color: color.onPrimary)),
                    backgroundColor: color.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Responsive.cardRadius(context))),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context) * 1.25,
                      vertical:   Responsive.spacing(context) * 0.625),
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        Responsive.cardRadius(context)),
                    border: Border.all(
                        color: color.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          color: color.primary,
                          size: Responsive.smallIcon(context)),
                      SizedBox(width: Responsive.spacing(context) * 0.5),
                      Text("Copy Password",
                          style: text.bodySmall?.copyWith(
                              color: color.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),

        SizedBox(
          height: Responsive.buttonHeight(context),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
            ),
            child: Text("Back to Sign In",
                style: text.titleSmall?.copyWith(
                    color: color.onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),

        SizedBox(height: Responsive.sectionSpacing(context) * 2),
      ],
    );
  }
}