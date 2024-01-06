import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

Map<String, SvgPicture> _storage = {};

class SvgLoader {
  static Widget asset(
    String path, {
    double width = 30,
    double height = 30,
    String def = 'assets/svg.svg',
  }) =>
      (_storage[path] != null
          ? _storage[path]!
          : FutureBuilder(
              future: islocal(path, def, width, height),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  _storage[path] = snapshot.data!;
                  return snapshot.data!;
                }
                return CircularProgressIndicator();
              },
            ));

  static Future<SvgPicture> islocal(
    String path, [
    String def = 'assets/svg.svg',
    double width = 30,
    double height = 30,
  ]) async =>
      (await isLocalAsset(path))
          ? SvgPicture.asset(
              path,
              width: width,
              height: height,
            )
          : SvgPicture.asset(
              def,
              width: width,
              height: height,
            );

  // Test if a file exists without throwing an Exception
  static Future<bool> isLocalAsset(String assetPath) async {
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
