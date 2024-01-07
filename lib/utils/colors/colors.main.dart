import 'package:flutter/material.dart';

_appliedTextTheme(textStyle) {
  return TextTheme(
    bodySmall: textStyle,
    bodyMedium: textStyle,
    bodyLarge: textStyle,
    labelSmall: textStyle,
    labelMedium: textStyle,
    labelLarge: textStyle,
    displaySmall: textStyle,
    displayMedium: textStyle,
    displayLarge: textStyle,
  );
}

extension CustomColors on ColorScheme {
  Color get kakao => const Color(0xffFEE500);

  Color get anchor => const Color(0xFF9DC9D6);

  Color get bull => const Color(0xff22ab94);

  Color get bear => const Color(0xfff23645);
}

class MyTheme {
  Brightness brightness;

  MyTheme({
    required this.brightness,
  }) {
    theme = ThemeData(
      brightness: brightness,
      colorScheme: const ColorScheme.dark().copyWith(
        brightness: brightness,
        background: _backgroundColor,
        primary: _primary,
        onPrimary: _onPrimary,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        tertiary: _tertiary,
      ),
      dividerColor: _dividerColor,
      dividerTheme: DividerThemeData(
        color: _dividerColor,
        thickness: 0,
      ),
      textTheme: _appliedTextTheme(_textStyle),
    );
  }

  bool get _d => brightness == Brightness.dark;

  Color get _textColor =>
      _d ? const Color(0xffD1D4DC) : const Color(0xff131722);

  Color get _backgroundColor =>
      _d ? const Color(0xFF22252E) : const Color(0xffe0e3eb);

  Color get _dividerColor =>
      _d ? const Color(0xFF242831) : const Color(0xFFCED1DB);

  Color get _primary => _d ? const Color(0xFF10131D) : const Color(0xffFFFFFF);

  Color get _onPrimary =>
      _d ? const Color(0xffAAAAAA) : const Color(0xffAAAAAA);

  Color get _onPrimaryContainer =>
      _d ? const Color(0xFF000811) : const Color(0xFFF1F1F1);

  Color get _secondary =>
      _d ? const Color(0xFF16223B) : const Color(0xFFAEB9D1);

  Color get _tertiary => _d ? const Color(0xFF3E5C97) : const Color(0xFF2C4992);

  TextStyle get _textStyle => TextStyle(color: _textColor);
  late ThemeData theme;
}

class AppColors {
  static const Color kakao = Color(0xffFEE500);

  static const Color bgDarker = Color(0xFF030D18);
  static const Color bgDark = Color(0xFF010207);
  static const Color bgMidDark = Color(0xFF111329);
  static const Color bgMid = Color(0xFF181633);
  static const Color bgMidBright = Color(0xFF16223B);
  static const Color bgBright = Color(0xFF17223D);
  static const Color bgBrighter = Color(0xFF26395E);
  static const Color bgOpacity = Color(0xFF29344B);

  static const Color textColor = Color(0xFFAAAAAA);
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
