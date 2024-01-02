import 'package:flutter/material.dart';

class Screen {
  BuildContext ctx;
  Screen(
    this.ctx,
  );
  MediaQueryData get _media => MediaQuery.of(ctx);
  double get w => _media.size.width;
  double get h => _media.size.height;
  double get c => h - kToolbarHeight - kBottomNavigationBarHeight;

  Ratio get ratio => Ratio(this);
}

class Ratio {
  Screen _screen;
  Ratio(this._screen);

  double w(double r) => _screen.w * r;
  double h(double r) => _screen.h * r;
  double c(double r) => _screen.c * r;
}
