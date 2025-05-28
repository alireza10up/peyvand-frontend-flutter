import 'package:flutter/material.dart';

class AppAssets {
  static const String logo = 'assets/images/logo.png';

  static Widget getLogoCircle({
    double size = 60,
    Color? logoColor,
    Color? backgroundColor = Colors.white,
    double padding = 8,
    bool withShadow = true,
    Color shadowColor = Colors.black12,
    Border? border,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: border,
        boxShadow: withShadow ? [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image.asset(
            logo,
            color: logoColor,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  static Widget logoSmall({Color? color, Color? backgroundColor}) =>
      getLogoCircle(size: 24, logoColor: color, backgroundColor: backgroundColor, padding: 4, withShadow: false);

  static Widget logoMedium({Color? color, Color? backgroundColor}) =>
      getLogoCircle(size: 40, logoColor: color, backgroundColor: backgroundColor, padding: 6);

  static Widget logoLarge({Color? color, Color? backgroundColor, required Color logoColor}) =>
      getLogoCircle(size: 120, logoColor: color, backgroundColor: backgroundColor, padding: 15);
}