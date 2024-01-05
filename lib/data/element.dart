import 'package:flutter/material.dart';
import 'package:flutterohddul/chart/treemap.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/svgloader.dart';

class Group {
  Group._();
  static final Group _instance = Group._();
  factory Group() => _instance;

  Map<String, GroupData> data = {};

  Future<void> load() async {
    if (Meta().group == null) return;
    final groupdatalist = Meta().group?.data;
    await Future.forEach(
      groupdatalist!.keys,
      (name) async {
        var groupdata = groupdatalist[name];
        data[name] = GroupData(
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
      },
    );
  }

  GroupData? fromName(String name) {
    if (!data.containsKey(name)) return null;
    return data[name];
  }

  // 미리 api로 읽어온 tree data를 GroupData 클래스에 추가
  Future<void> addTree() async {
    // final treedatalist = await Api().read(url: '/meta/light/tree.json');
    // final index = treedatalist['index']['group'];
    // await Future.forEach(treedatalist['group'], (treedata) async {
    // });
  }
}

class GroupData {
  String? name;
  List<String>? children;
  Function image = () => SvgLoader.asset('assets/error.svg');
  int? currentPrice;
  int? lastPrice;
  int? historicalPrice;
  Rectangle? tree;
  Color? get color => groupColor[name];

  GroupData({
    this.name,
    this.children,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
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

  Map<String, IndutyData> data = {};

  Future<void> load() async {
    if (Meta().induty == null) return;
    if (Meta().indutyIndex == null) return;
    final indutydatalist = Meta().induty?.data;
    final indutyindexlist = Meta().indutyIndex?.data;
    await Future.forEach(indutydatalist!.keys, (code) async {
      final indutydata = indutydatalist[code];
      final child = indutyindexlist?.entries
          .where((e) => e.value == code)
          .map((e) => e.key)
          .toList();
      return IndutyData(
        code: code,
        name: indutydata?['n'],
        child: child,
        currentPrice: indutydata?['p'],
      );
    });
  }
}

class IndutyData {
  String? name;
  String? code;
  List<String>? child;
  int? currentPrice;
  int? lastPrice;
  int? historicalPrice;
  IndutyData({
    this.name,
    this.code,
    this.child,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'currentPrice': currentPrice,
      'child': child,
    };
  }
}
