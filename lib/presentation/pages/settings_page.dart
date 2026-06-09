import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/settings_provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/presentation/screens/welcome_screen.dart';
import 'package:edulearn/presentation/widget/custom_toggle_widget.dart';
import 'package:edulearn/core/responsive.dart';

class SettingsPage extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const SettingsPage({super.key, this.onNavigateToTab});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // context.watch listens to settings provider to update UI themes immediately
    final settings = context.watch<SettingsProvider>();
    final theme    = Theme.of(context);
    final color    = theme.colorScheme;
    final text     = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Responsive.pagePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.pageTopSpacing(context)),

              Text("Settings",
                  style: text.headlineLarge?.copyWith(color: color.onSurface)),

              SizedBox(height: Responsive.afterTitleSpacing(context)),

              _section("Account", color, text),
              _tile("About App", Icons.info_outline_rounded,
                      () => _showAboutSheet(context), color, text),

              SizedBox(height: Responsive.sectionSpacing(context)),

              _section("Appearance", color, text),
              CustomToggle(
                title:    settings.isDarkMode ? "Dark Mode" : "Light Mode",
                subtitle: settings.isDarkMode ? "Dark theme active" : "Light theme active",
                value:    settings.isDarkMode,
                icon:     settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
              ),

              SizedBox(height: Responsive.sectionSpacing(context)),

              _section("App Experience", color, text),
              CustomToggle(
                title:    "Sound Effects",
                subtitle: "Controlled by system settings",
                value:    settings.soundEnabled,
                icon:     Icons.volume_up_rounded,
                onChanged: (v) => context.read<SettingsProvider>().setSoundEnabled(v),
              ),
              CustomToggle(
                title:    "Haptic Feedback",
                subtitle: "Controlled by system settings",
                value:    settings.hapticEnabled,
                icon:     Icons.vibration_rounded,
                onChanged: (v) => context.read<SettingsProvider>().setHapticEnabled(v),
              ),

              SizedBox(height: Responsive.sectionSpacing(context)),

              _section("Support & Legal", color, text),
              _tile("Privacy Policy", Icons.security_rounded,
                      () => _showPrivacySheet(context), color, text),

              SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

              _actionButton(
                label: "Sign Out",
                icon: Icons.logout_rounded,
                fgColor: color.primary,
                bgColor: color.surface,
                borderColor: color.primary.withValues(alpha: 0.25),
                text: text,
                onTap: () => _showSignOutDialog(context),
              ),

              SizedBox(height: Responsive.spacing(context)),

              _actionButton(
                label: "Delete Account",
                icon: Icons.delete_forever_rounded,
                fgColor: color.error,
                bgColor: color.errorContainer.withValues(alpha: 0.4),
                borderColor: color.error.withValues(alpha: 0.3),
                text: text,
                onTap: () => _showDeleteAccountDialog(context),
              ),

              SizedBox(height: Responsive.sectionSpacing(context) * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, ColorScheme color, TextTheme text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title,
          style: text.labelMedium?.copyWith(
              color: color.primary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }

  Widget _tile(String title, IconData icon, VoidCallback onTap,
      ColorScheme color, TextTheme text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(color: color.outline.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context), vertical: 4),
        leading: Icon(icon, color: color.primary),
        title: Text(title,
            style: text.bodyMedium?.copyWith(
                color: color.onSurface, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: color.primary, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color fgColor,
    required Color bgColor,
    required Color borderColor,
    required TextTheme text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context) * 0.875),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fgColor, size: Responsive.icon(context)),
            SizedBox(width: Responsive.spacing(context) * 0.75),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                      color: fgColor, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context))),
        title: Text("Sign Out",
            style: text.titleLarge?.copyWith(
                color: color.onSurface, fontWeight: FontWeight.w900)),
        content: Text("You will be signed out. You can log in again anytime.",
            style: text.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel",
                style: text.labelLarge?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false);
              }
            },
            child: Text("Sign Out",
                style: text.labelLarge?.copyWith(
                    color: color.primary, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context))),
        title: Text("Delete Account",
            style: text.titleLarge?.copyWith(
                color: color.error, fontWeight: FontWeight.w900)),
        content: Text(
            "This will permanently delete your account and all data. This cannot be undone.",
            style: text.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel",
                style: text.labelLarge?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false);
              }
            },
            child: Text("Delete",
                style: text.labelLarge?.copyWith(
                    color: color.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.radius(context)))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(Responsive.spacing(context) * 1.75),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45, height: 5,
                  decoration: BoxDecoration(
                      color: color.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Text("About EduLearn",
                  style: text.titleLarge?.copyWith(
                      color: color.onSurface, fontWeight: FontWeight.w900)),
              SizedBox(height: Responsive.spacing(context) * 1.25),
              _aboutRow(Icons.apps_rounded,   "App Name",  "EduLearn",                    color, text),
              _aboutRow(Icons.tag_rounded,    "Version",   "1.0.0",                       color, text),
              _aboutRow(Icons.person_rounded, "Developer", "Pelin Aksoy",                 color, text),
              _aboutRow(Icons.mail_rounded,   "Contact",   "edulearn.support@gmail.com",  color, text),
              SizedBox(height: Responsive.spacing(context) * 0.75),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value,
      ColorScheme color, TextTheme text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.buttonHeight(context) * 0.65,
            height: Responsive.buttonHeight(context) * 0.65,
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.radius(context) * 0.6)),
            child: Icon(icon, color: color.primary, size: Responsive.smallIcon(context)),
          ),
          SizedBox(width: Responsive.spacing(context) * 0.875),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: text.bodySmall?.copyWith(
                        color: color.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: text.bodyMedium?.copyWith(
                        color: color.onSurface, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.radius(context)))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(Responsive.spacing(context) * 1.75),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45, height: 5,
                  decoration: BoxDecoration(
                      color: color.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.5),
              Text("Privacy Policy",
                  style: text.titleLarge?.copyWith(
                      color: color.onSurface, fontWeight: FontWeight.w900)),
              SizedBox(height: Responsive.spacing(context)),
              Text(
                "Your data is stored locally and securely using SQLite on your device. "
                    "We do not share your personal information with third parties.",
                style: text.bodyMedium?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.6), height: 1.6),
              ),
              SizedBox(height: Responsive.spacing(context) * 1.25),
            ],
          ),
        ),
      ),
    );
  }
}