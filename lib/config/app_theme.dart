import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color accentColor = Color(0xFFF5A623);

  static const Color scaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFFF6B6B);

  // static const Color textColor = Color(0xFF222222);
  // static const Color textColorDark = Color(0xFFF1F1F1);
  // static const Color lightTextColor = Color(0xFF888888);

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: scaffoldBackgroundColor,
      surface: cardBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: primaryTextColor,
      onSurface: primaryTextColor,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazir',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      filled: true,
      fillColor: cardBackgroundColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: secondaryTextColor, fontFamily: 'Vazir'),
      labelStyle: TextStyle(color: secondaryTextColor, fontFamily: 'Vazir'),
      floatingLabelStyle: TextStyle(color: primaryColor),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTextColor, fontFamily: 'Vazir'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryTextColor, fontFamily: 'Vazir'),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: primaryTextColor, fontFamily: 'Vazir'),
      bodyLarge: TextStyle(fontSize: 16, color: primaryTextColor, fontFamily: 'Vazir'),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryTextColor, fontFamily: 'Vazir'),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Vazir'),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    iconTheme: IconThemeData(
      color: primaryTextColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );
}