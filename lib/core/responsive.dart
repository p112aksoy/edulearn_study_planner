import 'package:flutter/material.dart';

class Responsive {
  // for screen sizes
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static Size size(BuildContext context) =>
      MediaQuery.of(context).size;

  // for device types
  static bool isMobile(BuildContext context) =>
      width(context) < 650;

  static bool isTablet(BuildContext context) =>
      width(context) >= 650 && width(context) < 1100;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1100;

  // for padding
  static double padding(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 32;
    return 20;
  }

  static EdgeInsets screenPadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: padding(context));

  // for horizantal page padding
  // It is used on pages such as HomeScreen and SettingsPage
  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return width(context) * 0.15;
    if (isTablet(context)) return width(context) * 0.12;
    return 24;
  }

  // for card width
  static double cardWidth(BuildContext context) {
    if (isDesktop(context)) return 500;
    if (isTablet(context)) return 420;
    return width(context);
  }

  // for font sizes
  static double title(BuildContext context) {
    if (isDesktop(context)) return 34;
    if (isTablet(context)) return 30;
    return 28;
  }

  static double heading(BuildContext context) {
    if (isDesktop(context)) return 26;
    if (isTablet(context)) return 22;
    return 18;
  }

  static double body(BuildContext context) {
    if (isDesktop(context)) return 18;
    if (isTablet(context)) return 16;
    return 14;
  }

  static double small(BuildContext context) {
    if (isDesktop(context)) return 15;
    if (isTablet(context)) return 14;
    return 12;
  }

  // for icon sizes
  static double icon(BuildContext context) {
    if (isDesktop(context)) return 30;
    if (isTablet(context)) return 26;
    return 22;
  }

  static double smallIcon(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 22;
    return 18;
  }

  // for avatar, ı made
  static double avatarRadius(BuildContext context) {
    if (isDesktop(context)) return 80;
    if (isTablet(context)) return 70;
    return 58;
  }

  // for spacing
  static double spacing(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  // for standard spacing between page title and app bar
  static double pageTopSpacing(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) return 36;
    return 28;
  }

  //for space between headers and contents
  static double afterTitleSpacing(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) return 36;
    return 28;
  }

  // for space between sections
  static double sectionSpacing(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) return 32;
    return 24;
  }

  static double radius(BuildContext context) {
    if (isDesktop(context)) return 30;
    if (isTablet(context)) return 26;
    return 20;
  }

  static double cardRadius(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) return 26;
    return 20;
  }

  // for button
  static double buttonHeight(BuildContext context) {
    if (isDesktop(context)) return 64;
    if (isTablet(context)) return 60;
    return 56;
  }

  // for app bar, ı did
  static double appBarHeight(BuildContext context) {
    if (isDesktop(context)) return 85;
    if (isTablet(context)) return 75;
    return kToolbarHeight;
  }
}