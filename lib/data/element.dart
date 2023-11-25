import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/data/api.dart';

class Group {
  String? name;
  List<String>? child;
  SvgPicture? image;
  int? currentPrice;
  int? lastPrice;
  int? historicalPrice;

  Group({
    this.name,
    this.child,
    this.image,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
  });

  static Group? fromName(String? name) {
    if (name == null) return null;
    final data = Meta().group?.data?[name];
    return Group(
      name: name,
      image: SvgPicture.asset('assets/group/$name.svg'),
      child: List<String>.from(data?['ch']?.map((e) => e)),
      currentPrice: data?['c'],
      lastPrice: data?['p'],
      historicalPrice: data?['h'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currentPrice': currentPrice,
      'lastPrice': lastPrice,
      'historicalPrice': historicalPrice,
      'child': child,
    };
  }
}

class Induty {
  String? name;
  String? code;
  List<String>? child;
  int? currentPrice;
  int? lastPrice;
  int? historicalPrice;
  Induty({
    this.name,
    this.code,
    this.child,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
  });

  static Induty? fromCode(String? code) {
    if (code == null) return null;
    final data = Meta().induty?.data?[code];
    final child = Meta()
        .indutyIndex
        ?.data
        ?.entries
        .where((e) => e.value == code)
        .map((e) => e.key)
        .toList();
    return Induty(
      code: code,
      name: data?['n'],
      child: child,
      currentPrice: data?['p'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'currentPrice': currentPrice,
      'child': child,
    };
  }
}
