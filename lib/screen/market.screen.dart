import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/chart/ecoschart.dart';
import 'package:flutterohddul/chart/treemap.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:flutterohddul/utils/base/base.dart';

class BarState {
  String name;
  IconData? icon;
  List<BarState> child;
  dynamic data;

  BarState({
    required this.name,
    required this.icon,
    required this.child,
    required this.data,
  });

  BarState from(List<int> currentIndex) {
    return child[currentIndex[0]].child[currentIndex[1]];
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _names = ['기준금리', 'CPI', '그룹', '업종'];
  int i = 0;

  _customBar(BuildContext context) {
    var theme = Theme.of(context);
    button(text, j) {
      return GestureDetector(
        onTap: () {
          setState(() {
            i = j;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: i == j ? theme.dividerColor : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
      );
    }

    return Section(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: _names.mapIndexed((i, e) => button(e, i)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _customBar(context),
        const SizedBox(height: 2),
        [
          EcosChartWidget(
            data: Market().baserate,
            duration: const Duration(days: 365 * 4),
          ),
          EcosChartWidget(
            data: Market().cpi,
            duration: const Duration(days: 365 * 4),
          ),
          Container(
            child: TreeMapWidget(),
          ),
        ][i],
      ],
    );
  }
}
