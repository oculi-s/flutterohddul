import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/data/api.dart';

class Stock {
  bool valid = true;
  String? code;
  String? name;
  String? marketType;
  int? amount;
  Group? group;
  Induty? induty;
  int? currentPrice, lastPrice, historicalPrice, priceChange;
  double? priceChangeRatio;

  Stock({
    required this.valid,
    this.code,
    this.name,
    this.induty,
    this.group,
    this.marketType,
    this.amount,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
    this.priceChange,
    this.priceChangeRatio,
  });

  factory Stock.fromCode(String code) {
    final data = Meta().meta?.data?.entries.firstWhere((e) {
      return e.key == code || e.value['n'] == code;
    }).value;
    if (data == null) return Stock(valid: false);
    final groupName = Meta().group?.index?[code];
    final indutyCode = Meta().indutyIndex?.data?[code];
    int currentPrice = Meta().price?.data?[code]?['c'] ?? 0;
    int lastPrice = Meta().price?.data?[code]?['p'] ?? 0;
    int historicalPrice = Meta().hist?.data?[code]?['h'] ?? 0;

    return Stock(
      valid: true,
      code: code,
      name: data?['n'],
      amount: data?['a'],
      marketType: data?['t'],
      group: Group.fromName(groupName),
      induty: Induty.fromCode(indutyCode),
      currentPrice: currentPrice,
      lastPrice: lastPrice,
      historicalPrice: historicalPrice,
      priceChange: lastPrice - currentPrice,
      priceChangeRatio: (lastPrice - currentPrice) / lastPrice * 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'amount': amount,
      'marketType': marketType,
      'group': group?.toJson(),
      'induty': induty?.toJson(),
    };
  }
}

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
