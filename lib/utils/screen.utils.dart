import 'package:flutter/material.dart';

class Screen {
  BuildContext context;
  Screen(
    this.context,
  );
  MediaQueryData get _media => MediaQuery.of(context);
  double get w => _media.size.width;
  double get h => _media.size.height;
  double get c => h - kBottomNavigationBarHeight; // - kToolbarHeight;

  Ratio get ratio => Ratio(this);
}

class Ratio {
  final Screen _screen;
  Ratio(this._screen);

  double w(double r) => _screen.w * r;
  double h(double r) => _screen.h * r;
  double c(double r) => _screen.c * r;
}
