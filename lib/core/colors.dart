import 'package:flutter/material.dart';
import 'package:flutterohddul/core/colors.dart';

class DarkTheme {
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'NotoSansKR',
    canvasColor: AppColors.bgDark,
    focusColor: Color(0xff006AB5),
    primaryColor: AppColors.textBright,
    highlightColor: Color(0xffe5e5e5),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textBright,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class LightTheme {
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'NotoSansKR',
    canvasColor: AppColors.bgBright,
    primaryColor: AppColors.textDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textBright,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class AppColors {
  static const Color kakao = Color(0xFFFEE500);

  static const Color bgDarker = Color(0xFF030D18);
  static const Color bgDark = Color.fromARGB(255, 1, 2, 7);
  static const Color bgMidDark = Color(0xFF111329);
  static const Color bgMid = Color(0xFF181633);
  static const Color bgMidBright = Color(0xFF16223B);
  static const Color bgBright = Color(0xFF17223D);
  static const Color bgBrighter = Color(0xFF26395E);
  static const Color bgOpacity = Color(0xFF29344B4B);

  static const Color textColor = Color(0xFFAAA);
  static const Color textBright = Color(0xFFE5E5E5);
  static const Color textDark = Color(0xFF8A8A8A);
  static const Color anchor = Color(0xFF9DC9D6);
  static const Color anchorBright = Color(0xFFC2D8DF);

  static const Color borderColor = Color(0xFF1A1A2D);
  static const Color barColor = Color(0xFF313B53);
  static const Color thColor = Color(0xFF111327);
  static const Color tbColor = Color(0xFF14172E);

  static const Color red = Color(0xFFE3665D);
  static const Color redDark = Color(0xFF612D29);
  static const Color redBright = Color(0xFFE33327);
  static const Color blue = Color(0xFF727DDD);
  static const Color blueDark = Color(0xFF323764);
  static const Color blueBright = Color(0xFF3A4BE0);
  static const Color green = Color(0xFF5BA76E);

  static const Color tradeUp = Color(0xFF26A69A);
  static const Color tradeDown = Color(0xFFEF5350);

  static const Color unranked = Color(0xFF383838);
  static const Color bronze = Color(0xFF884E1E);
  static const Color silver = Color(0xFF7E7E7E);
  static const Color gold = Color(0xFFBDB32A);
  static const Color platinum = Color(0xFF4AEBBA);
  static const Color diamond = Color(0xFF4A9DEB);
  static const Color master = Color(0xFFEB4A4A);
}
