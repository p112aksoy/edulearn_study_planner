import 'package:flutter/material.dart';

class AppColors {
  static const Color pink1 = Color(0xFFFFEDFA);
  static const Color pink2 = Color(0xFFFFB8E0);
  static const Color pink3 = Color(0xFFEC7FA9);
  static const Color pink4 = Color(0xFFBE5985);

  static const Color lightBg      = Color(0xFFF3B7CA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText    = Color(0xFF4A1D30);
  static const Color lightSubText = Color(0xFF8E5D72);

  static const Color darkBg      = Color(0xFF2D1621);
  static const Color darkSurface = Color(0xFF3D1F2D);
  static const Color darkText    = Color(0xFFDDB2B2);
  static const Color darkSubText = Color(0xFFD1A7B9);
}

class AppTheme {
  static TextTheme _textTheme(Color text, Color subText) {
    return TextTheme(
      headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, color: text),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: text),
      headlineSmall:  TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: text),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: text),
      titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
      titleSmall:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: text),
      bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text),
      bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: subText),
      labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text),
      labelMedium:    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subText),
      labelSmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subText),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        splashFactory: NoSplash.splashFactory,   // no flash
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        splashFactory: NoSplash.splashFactory,   //no flash
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static IconButtonThemeData _iconButtonTheme() {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        splashFactory: NoSplash.splashFactory,   // no flash
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    primaryColor: AppColors.pink3,
    splashFactory: NoSplash.splashFactory,       //  InkWell flash is not in my project
    splashColor: Colors.transparent,             //
    highlightColor: Colors.transparent,          //
    colorScheme: const ColorScheme.light(
      surface:        AppColors.lightSurface,
      primary:        AppColors.pink3,
      onPrimary:      Colors.white,
      secondary:      AppColors.pink4,
      onSecondary:    Colors.white,
      onSurface:      AppColors.lightText,
      error:          Color(0xFFB00020),
      onError:        Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      outline:        AppColors.lightSubText,
    ),
    textTheme:           _textTheme(AppColors.lightText, AppColors.lightSubText),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    iconButtonTheme:     _iconButtonTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    primaryColor: AppColors.pink3,
    splashFactory: NoSplash.splashFactory,       //  InkWell flash is not for my project
    splashColor: Colors.transparent,             //
    highlightColor: Colors.transparent,          //
    colorScheme: const ColorScheme.dark(
      surface:        AppColors.darkSurface,
      primary:        AppColors.pink3,
      onPrimary:      Colors.white,
      secondary:      AppColors.pink4,
      onSecondary:    Colors.white,
      onSurface:      AppColors.darkText,
      error:          Color(0xFFCF6679),
      onError:        Colors.black,
      errorContainer: Color(0xFF8C1D18),
      outline:        AppColors.darkSubText,
    ),
    textTheme:           _textTheme(AppColors.darkText, AppColors.darkSubText),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    iconButtonTheme:     _iconButtonTheme(),
  );
}
