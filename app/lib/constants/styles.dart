import 'package:flutter/material.dart';

Color primary = Color(0xFF1B4444);
class Styles {
  static Color primaryColor = primary;
  static Color primaryAccent = const Color(0xFF296363);
  static Color secondaryColor = const Color(0xFF84D19B);
  static Color secondaryAccent = const Color(0xFF84DE9E);
  static Color bgColor = const Color(0xFFF5F5F5);
  static Color warningColor = const Color(0xFFFDA715);
  static Color dangerColor = const Color(0xFFE74C3C);
  static Color successColor = const Color(0xFF2ECC71);
  static Color infoColor = const Color(0xFF0ABDE3);
  // static Color fontColor = const Color(0xFF10161C);
  static Color fontColor = const Color(0xFFF5F5F5);
  static Color fontColorLight = const Color(0xFFD4D4D4);
  static Color fontDarkColor = const Color(0xFF232426);
  static Color fontDarkColorLight = const Color(0xFF47494D);
  static Color fontColorWhite = const Color(0xFFF5F5F5);
  static Color shadowColor = const Color(0xFFB5B4B3);

//   Font Styles
  static TextStyle defaultFont = TextStyle(fontSize: 16, color: fontColorLight);
  static TextStyle titleFont = TextStyle(fontSize: 26, color: fontColor, fontWeight: FontWeight.bold);
  static TextStyle titleDarkFont = TextStyle(fontSize: 26, color: fontDarkColor, fontWeight: FontWeight.bold);
  static TextStyle subTitleFont = TextStyle(fontSize: 18, color: fontColorLight, fontWeight: FontWeight.w500);
  static TextStyle subTitleDarkFont = TextStyle(fontSize: 18, color: fontDarkColorLight, fontWeight: FontWeight.w500);

}
