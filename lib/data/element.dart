import 'package:flutterohddul/data/api.dart';

class Stock {
  String? code;
  String? name;
  String? marketType;
  int? amount;
  Group? group;
  Induty? induty;

  Stock({
    this.code,
    this.name,
    this.induty,
    this.group,
    this.marketType,
    this.amount,
  });

  factory Stock.fromCode(String code) {
    final data = Meta().meta?.data?[code];
    final groupName = Meta().group?.index?[code];
    final indutyCode = Meta().indutyIndex?.data?[code];
    return Stock(
      code: code,
      name: data?['n'],
      amount: data?['a'],
      marketType: data?['t'],
      group: Group.fromName(groupName),
      induty: Induty.fromCode(indutyCode),
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
  int? currentPrice;
  int? lastPrice;
  int? historicalPrice;

  Group({
    this.name,
    this.child,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
  });

  factory Group.fromName(String name) {
    final data = Meta().group?.data?[name];
    return Group(
      name: name,
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

  factory Induty.fromCode(String code) {
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
