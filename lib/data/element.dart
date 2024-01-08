import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/utils/base/vars.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:flutterohddul/utils/svgloader.dart';

class Group {
  Group._();
  static final Group _instance = Group._();
  factory Group() => _instance;

  List<GroupData> data = [];

  List<double> get price =>
      data.map((e) => e.currentPrice?.toDouble() ?? 0).toList();
  List<Widget> get image => data.map((e) => e.image()).toList();
  List<Color?> get colors => data.map((e) => e.color).toList();

  Future<void> load() async {
    if (Meta().group == null) return;
    final groupdatalist = Meta().group?.data;

    data = groupdatalist!.keys
        .map((name) {
          var groupdata = groupdatalist[name];
          return GroupData(
            name: name,
            image: ([double width = 30, double height = 30]) => SvgLoader.asset(
              'assets/group/$name.svg',
              width: width.toDouble(),
              height: height.toDouble(),
            ),
            children: List.from(groupdata?['ch']?.map((e) => e)),
            currentPrice: groupdata?['c'],
            lastPrice: groupdata?['p'],
            historicalPrice: groupdata?['h'],
          );
        })
        .sortedBy2((e) => e.currentPrice ?? 0)
        .reversed
        .toList();
  }

  GroupData? fromName(name) => data.firstWhereOrNull((e) => e.name == name);
}

class GroupData {
  String name;
  List<String> children;
  Widget Function() image = () => SvgLoader.asset('assets/error.svg');
  int currentPrice;
  int lastPrice;
  int historicalPrice;
  Color? get color => groupColor[name];

  GroupData({
    this.name = '',
    this.children = const [],
    this.currentPrice = 0,
    this.lastPrice = 0,
    this.historicalPrice = 0,
    required this.image,
  });

  String get imageUrl => 'assets/group/$name.svg';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currentPrice': currentPrice,
      'lastPrice': lastPrice,
      'historicalPrice': historicalPrice,
      'child': children,
    };
  }
}

class Induty {
  Induty._();
  static final Induty _instance = Induty._();
  factory Induty() => _instance;

  List<IndutyData> data = [];

  Future<void> load() async {
    if (Meta().induty == null) return;
    if (Meta().indutyIndex == null) return;
    final indutyMap = Meta().induty?.data;
    final indexMap = Meta().indutyIndex?.data;
    data = indutyMap!.keys
        .map((code) {
          final indutydata = indutyMap[code];
          final child = indexMap?.entries
              .where((e) => e.value == code)
              .map((e) => e.key)
              .toList();
          return IndutyData(
            code: code,
            name: indutydata?['n'],
            child: child ?? [],
            currentPrice: indutydata?['p'],
          );
        })
        .sortedBy2((a) => a.currentPrice)
        .reversed
        .toList();
  }

  IndutyData? fromCode(code) => data.firstWhereOrNull((e) => e.code == code);
}

class IndutyData {
  String name;
  String code;
  List<String> child;
  int currentPrice;
  int lastPrice;
  int historicalPrice;
  IndutyData({
    this.name = '',
    this.code = '',
    this.child = const [],
    this.currentPrice = 0,
    this.lastPrice = 0,
    this.historicalPrice = 0,
  });
  Icon? get icon => indutyIcons[name] != null ? Icon(indutyIcons[name]) : null;
  Color? get color => indutyColors[name];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'currentPrice': currentPrice,
      'child': child,
    };
  }
}
