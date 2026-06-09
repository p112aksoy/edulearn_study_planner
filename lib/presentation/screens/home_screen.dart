import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edulearn/logic/providers/home_provider.dart';
import 'package:edulearn/presentation/pages/courses_page.dart';
import 'package:edulearn/presentation/pages/pomodoro_page.dart';
import 'package:edulearn/presentation/pages/profile_page.dart';
import 'package:edulearn/presentation/pages/settings_page.dart';
import 'package:edulearn/presentation/widget/app_bar_widget.dart';
import 'package:edulearn/presentation/widget/mood_panel.dart';
import 'package:edulearn/presentation/widget/deadline_section.dart';
import 'package:edulearn/presentation/widget/scratchpad_section.dart';
import 'package:edulearn/core/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final pages = [
      _buildHomeTab(color),
      const CoursesPage(),
      const PomodoroPage(),
      const ProfilePage(),
      SettingsPage(
          onNavigateToTab: (i) => setState(() => _currentIndex = i)),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const EduLearnAppBar(),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(color),
    );
  }

  // for home tab
  Widget _buildHomeTab(ColorScheme color) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.pagePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.pageTopSpacing(context)),
          Text("Welcome",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color.onSurface)),
          SizedBox(height: Responsive.afterTitleSpacing(context)),

          // seperated widget
          const MoodPanel(),

          SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

          // seperated widget
          const DeadlineSection(),

          SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

          // seperated widget
          const ScratchpadSection(),

          SizedBox(height: Responsive.sectionSpacing(context) * 5),
        ],
      ),
    );
  }

  // this is important one: bottom nav part*
  Widget _buildBottomNav(ColorScheme color) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: color.surface,
        selectedItemColor: color.primary,
        unselectedItemColor: color.onSurface.withValues(alpha: 0.3),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: "Courses"),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled_rounded), label: "Focus"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_suggest_rounded), label: "Settings"),
        ],
      ),
    );
  }
}