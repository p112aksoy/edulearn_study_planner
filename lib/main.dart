import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edulearn/core/app_theme.dart';

import 'package:edulearn/data/repositories/course_repository.dart';

import 'package:edulearn/logic/providers/courses.provider.dart';
import 'package:edulearn/logic/providers/settings_provider.dart';
import 'package:edulearn/logic/providers/auth_provider.dart';
import 'package:edulearn/logic/providers/home_provider.dart';
import 'package:edulearn/logic/providers/study_provider.dart';

import 'package:edulearn/presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final authProvider = AuthProvider();

  await Future.wait([
    settingsProvider.loadSettings(),
    authProvider.checkLoginStatus(),
  ]);

  runApp(EduLearnApp(
    settingsProvider: settingsProvider,
    authProvider: authProvider,
  ));
}

class EduLearnApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final AuthProvider authProvider;

  const EduLearnApp({
    super.key,
    required this.settingsProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CORE
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),

        // STUDY
        ChangeNotifierProvider<StudyProvider>(
          create: (_) => StudyProvider(),
        ),

        // COURSES — userId'yi AuthProvider'dan alıyor
        // Kullanıcı değişince (login/logout) CoursesProvider yeniden oluşturuluyor
        ChangeNotifierProxyProvider<AuthProvider, CoursesProvider>(
          create: (_) => CoursesProvider(
            repository: CourseRepository(),
            userId: authProvider.currentUser?.id ?? 0,
          ),
          update: (ctx, auth, previous) {
            final uid = auth.currentUser?.id ?? 0;
            // Aynı kullanıcıysa mevcut provider'ı koru
            if (previous != null && previous.userId == uid) return previous;
            // Farklı kullanıcı — yeni provider oluştur ve kursları yükle
            final provider = CoursesProvider(
              repository: CourseRepository(),
              userId: uid,
            );
            if (uid != 0) provider.loadCourses();
            return provider;
          },
        ),

        // HOME — userId'yi AuthProvider'dan alıyor
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (_) => HomeProvider(
            userId: authProvider.currentUser?.id ?? 0,
          ),
          update: (ctx, auth, previous) {
            final uid = auth.currentUser?.id ?? 0;
            // Aynı kullanıcıysa mevcut provider'ı koru
            if (previous != null && previous.userId == uid) return previous;
            // Farklı kullanıcı — yeni provider oluştur (constructor içinde loadAllData çağrılır)
            return HomeProvider(userId: uid);
          },
        ),
      ],

      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'EduLearn',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}