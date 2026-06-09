import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/core/responsive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  // Her kullanıcının fotoğrafı ayrı kaydedilir — key: profile_image_<userId>
  String _imageKey(int userId) => 'profile_image_$userId';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString(_imageKey(userId));
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    try {
      final XFile? selected = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (selected != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey(userId), selected.path);
        setState(() => _profileImagePath = selected.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _removeImage() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imageKey(userId));
    setState(() => _profileImagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    final user  = context.watch<AuthProvider>().currentUser;
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text  = theme.textTheme;

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

              // for profile image(editing your photo)
              Center(
                child: GestureDetector(
                  onTap: () => _showSourceOptions(context),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [color.primary, color.secondary]),
                        ),
                        child: CircleAvatar(
                          radius: Responsive.avatarRadius(context),
                          backgroundColor: color.surface,
                          child: ClipOval(
                            child: _profileImagePath != null
                                ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                              width:  Responsive.avatarRadius(context) * 2,
                              height: Responsive.avatarRadius(context) * 2,
                            )
                                : Icon(Icons.person,
                                size:  Responsive.avatarRadius(context) * 0.85,
                                color: color.primary),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: color.surface, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded,
                              size: Responsive.smallIcon(context),
                              color: color.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Responsive.afterTitleSpacing(context)),

              // this is for personal information
              _sectionTitle("Personal Information", color, text),
              _infoTile("Full Name",  user?.fullName  ?? "-", Icons.badge,       color, text),
              _infoTile("Email",      user?.email     ?? "-", Icons.email,       color, text),
              _infoTile("Student ID", user?.studentId ?? "-", Icons.fingerprint, color, text),

              SizedBox(height: Responsive.sectionSpacing(context)),

              // for educational background
              _sectionTitle("Educational Background", color, text),
              _infoTile("Current Major", user?.major  ?? "-", Icons.school,           color, text),
              _infoTile("School",        user?.school ?? "-", Icons.account_balance,  color, text),
              _infoTile("Current Year",  user?.year   ?? "-", Icons.calendar_today,   color, text),

              SizedBox(height: Responsive.sectionSpacing(context) * 2),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceOptions(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.radius(context)))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context) * 0.875),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: EdgeInsets.only(bottom: Responsive.spacing(context)),
                decoration: BoxDecoration(
                    color: color.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: color.primary),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { _pickImage(ImageSource.gallery); Navigator.pop(ctx); },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: color.primary),
                title: const Text('Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { _pickImage(ImageSource.camera); Navigator.pop(ctx); },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  title: const Text('Remove Photo',
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () { _removeImage(); Navigator.pop(ctx); },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme color, TextTheme text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context)),
      child: Text(title,
          style: text.titleLarge?.copyWith(
              color: color.primary, fontWeight: FontWeight.w800)),
    );
  }

  Widget _infoTile(String label, String value, IconData icon,
      ColorScheme color, TextTheme text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: Responsive.spacing(context) * 0.875),
      padding: EdgeInsets.all(Responsive.padding(context) * 0.9),
      decoration: BoxDecoration(
        color: color.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(
            color: color.primary.withValues(alpha: 0.18), width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context) * 0.625),
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    Responsive.radius(context) * 0.6)),
            child: Icon(icon, color: color.primary,
                size: Responsive.smallIcon(context)),
          ),
          SizedBox(width: Responsive.spacing(context) * 0.875),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: text.labelMedium?.copyWith(
                        color: color.onSurface.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    overflow: TextOverflow.visible,
                    style: text.bodyLarge?.copyWith(
                        color: color.onSurface, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}