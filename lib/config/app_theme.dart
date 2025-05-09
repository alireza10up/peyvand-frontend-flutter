import 'package:flutter/material.dart';

class AppTheme {
  // رنگ‌های اصلی
  static const Color primaryColor = Color(0xFFFF7D00); // Orange
  static const Color secondaryColor = Color(0xFF505050); // خاکستری تیره
  static const Color accentColor = Color(0xFF4ECDC4); // Cyan/Teal
  static const Color backgroundColor = Color(0xFFF6F6F9); // روشن
  static const Color backgroundColorDark = Color(0xFF101014); // دارک دارک واقعی
  static const Color surfaceColor = Color(0xFFFFFFFF); // کارت، اینپوت (لایت)
  static const Color surfaceColorDark = Color(0xFF19191F); // کارت، اینپوت (دارک)
  static const Color errorColor = Color(0xFFFF6B6B);

  // رنگ متن و متن روشن (برای استفاده در کل پروژه)
  static const Color textColor = Color(0xFF222222); // متن اصلی (لایت)
  static const Color textColorDark = Color(0xFFF1F1F1); // متن اصلی (دارک)
  static const Color lightTextColor = Color(0xFF888888); // متن کم‌رنگ (لایت و دارک)
  static const Color hintColorDark = Color(0xFF757585); // hint در دارک

  // تم روشن
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onBackground: textColor,
      onSurface: textColor,
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: lightTextColor, fontFamily: 'Vazir'),
      labelStyle: TextStyle(color: lightTextColor, fontFamily: 'Vazir'),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Vazir',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Vazir',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColor,
        fontFamily: 'Vazir',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightTextColor,
        fontFamily: 'Vazir',
      ),
    ),
    cardColor: surfaceColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );

  // تم دارک
  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColorDark,
      surface: surfaceColorDark,
      error: errorColor,
      onPrimary: Colors.white,
      onBackground: textColorDark,
      onSurface: textColorDark,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColorDark,
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF232334)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      filled: true,
      fillColor: surfaceColorDark,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: lightTextColor, fontFamily: 'Vazir'),
      labelStyle: TextStyle(color: lightTextColor, fontFamily: 'Vazir'),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColorDark,
        fontFamily: 'Vazir',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColorDark,
        fontFamily: 'Vazir',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColorDark,
        fontFamily: 'Vazir',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightTextColor,
        fontFamily: 'Vazir',
      ),
    ),
    cardColor: surfaceColorDark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColorDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );
}