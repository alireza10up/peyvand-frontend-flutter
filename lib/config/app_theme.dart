import 'package:flutter/material.dart';

class AppTheme {
  // رنگ‌های اصلی بر اساس UI Kit
  static const Color primaryColor = Color(0xFF4A90E2); // آبی دانشگاهی [cite: 3, 109]
  static const Color accentColor = Color(0xFFF5A623);  // نارنجی دوستانه [cite: 3, 110]

  // رنگ‌های خنثی و متن بر اساس UI Kit
  static const Color scaffoldBackgroundColor = Color(0xFFF4F6F8); // یا سفید #FFFFFF
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFFF6B6B); // رنگ خطا (می‌تواند از UI Kit یا یک استاندارد باشد)

  // رنگ متن و متن روشن (برای استفاده در کل پروژه) - قبلی
  // static const Color textColor = Color(0xFF222222);
  // static const Color textColorDark = Color(0xFFF1F1F1);
  // static const Color lightTextColor = Color(0xFF888888); // این می‌تواند همان secondaryTextColor باشد

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor, // استفاده از accentColor به جای secondaryColor در colorScheme
      background: scaffoldBackgroundColor,
      surface: cardBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white, // متن روی رنگ اصلی
      onSecondary: Colors.black, // متن روی رنگ تاکیدی
      onBackground: primaryTextColor,
      onSurface: primaryTextColor,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor, // AppBar با رنگ اصلی
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
        backgroundColor: primaryColor, // دکمه‌های اصلی با رنگ اصلی
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // گوشه‌های کمی گرد
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
        borderRadius: BorderRadius.circular(8.0), // گوشه‌های کمی گرد
        borderSide: BorderSide(color: dividerColor), // بوردر با رنگ جداکننده
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
      hintStyle: TextStyle(color: secondaryTextColor, fontFamily: 'Vazir'), // متن راهنما با رنگ متن ثانویه
      labelStyle: TextStyle(color: secondaryTextColor, fontFamily: 'Vazir'), // لیبل با رنگ متن ثانویه
      floatingLabelStyle: TextStyle(color: primaryColor), // لیبل شناور با رنگ اصلی
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTextColor, fontFamily: 'Vazir'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryTextColor, fontFamily: 'Vazir'),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: primaryTextColor, fontFamily: 'Vazir'), // برای عنوان AppBarها اگر پیش‌فرض کافی نبود
      bodyLarge: TextStyle(fontSize: 16, color: primaryTextColor, fontFamily: 'Vazir'), // متن اصلی
      bodyMedium: TextStyle(fontSize: 14, color: secondaryTextColor, fontFamily: 'Vazir'), // متن ثانویه
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Vazir'), // برای متن دکمه‌های اصلی
    ),
    cardTheme: CardTheme(
      elevation: 2, // سایه ملایم برای کارت‌ها
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // گوشه‌های گرد کارت‌ها
      ),
      color: cardBackgroundColor, // پس‌زمینه کارت‌ها
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    iconTheme: IconThemeData(
      color: primaryTextColor, // رنگ پیش‌فرض آیکون‌ها
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackgroundColor, // پس‌زمینه سفید یا رنگ کارت
      selectedItemColor: primaryColor, // آیتم فعال با رنگ اصلی
      unselectedItemColor: secondaryTextColor, // آیتم غیرفعال با رنگ متن ثانویه
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    // تم تیره فعلاً مورد نیاز نیست، اما ساختار آن حفظ می‌شود
    // static final ThemeData darkTheme = ThemeData(...);
  );
}