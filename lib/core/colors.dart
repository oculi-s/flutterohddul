import 'package:flutter/material.dart';

const double size = 15;

class DarkTheme {
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppColors.dark.backgroundColor,
    fontFamily: 'NotoSansKR',
    canvasColor: AppColors.dark.blockColor,
    focusColor: const Color(0xff006AB5),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.dark.defaultTextColor,
        fontWeight: FontWeight.w600,
        fontSize: size * 1.2,
      ),
      bodyMedium: TextStyle(
        color: AppColors.dark.defaultTextColor,
        fontWeight: FontWeight.w400,
        fontSize: size,
      ),
      bodySmall: TextStyle(
        color: AppColors.dark.defaultTextColor,
        fontSize: size * .8,
      ),
    ),
    dividerColor: AppColors.dark.backgroundColor,
    dividerTheme: DividerThemeData(
      color: AppColors.dark.backgroundColor,
      thickness: 0,
    ),
  );
}

class LightTheme {
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppColors.light.backgroundColor,
    fontFamily: 'NotoSansKR',
    canvasColor: AppColors.light.blockColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.light.defaultTextColor,
        fontWeight: FontWeight.w600,
        fontSize: size * 1.2,
      ),
      bodyMedium: TextStyle(
        color: AppColors.light.defaultTextColor,
        fontWeight: FontWeight.w400,
        fontSize: size,
      ),
      bodySmall: TextStyle(
        color: AppColors.light.defaultTextColor,
        fontSize: size * .8,
      ),
    ),
    dividerColor: AppColors.light.backgroundColor,
    dividerTheme: DividerThemeData(
      color: AppColors.light.backgroundColor,
      thickness: 0,
      endIndent: 0,
      space: 0,
    ),
  );
}

class ColorMap {
  Color backgroundColor;
  Color blockColor;

  Color defaultTextColor;
  Color subTextColor;
  Color indicatorContainerColor;
  Color borderColor;

  ColorMap({
    required this.backgroundColor,
    required this.blockColor,
    required this.defaultTextColor,
    required this.subTextColor,
    required this.indicatorContainerColor,
    required this.borderColor,
  });
}

class AppColors {
  static ColorMap dark = ColorMap(
    backgroundColor: const Color(0xff2a2e39),
    blockColor: const Color(0xff131722),
    defaultTextColor: const Color(0xffD1D4DC),
    subTextColor: const Color(0xff868993),
    indicatorContainerColor: const Color(0xff131722),
    borderColor: const Color(0xff2A2E39),
  );

  static ColorMap light = ColorMap(
    backgroundColor: const Color(0xffe0e3eb),
    blockColor: const Color(0xffFFFFFF),
    defaultTextColor: const Color(0xff131722),
    subTextColor: const Color(0xff6a6d78),
    indicatorContainerColor: const Color(0xffFFFFFF),
    borderColor: const Color(0xfff0F3FA),
  );
  static const Color kakao = Color(0xffFEE500);

  static const Color plus = Color(0xff22ab94);
  static const Color minus = Color(0xfff23645);

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
