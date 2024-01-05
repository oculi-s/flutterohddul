import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/chart/ecoschart.dart';
import 'package:flutterohddul/chart/treemap.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/base/vars.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

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

class _MarketScreenState extends State<MarketScreen> {
  final _currentBar = BarState(
    name: "",
    icon: null,
    child: [
      BarState(
        name: "세계경제",
        icon: Icons.language_rounded,
        child: [
          BarState(
            name: "기준금리",
            icon: Icons.bar_chart_rounded,
            child: [],
            data: Market().baserate,
          ),
          BarState(
            name: "CPI",
            icon: Icons.trending_up_rounded,
            child: [],
            data: Market().cpi,
          ),
        ],
        data: null,
      ),
      BarState(
        name: "한국경제",
        icon: Icons.flag_rounded,
        child: [
          BarState(
            name: "시총비중 (그룹)",
            icon: Icons.pie_chart_rounded,
            child: [],
            data: null,
          ),
        ],
        data: null,
      )
    ],
    data: null,
  );

  int i = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          backgroundColor: theme.colorScheme.primary,
          selectedItemColor: theme.colorScheme.tertiary,
          showUnselectedLabels: false,
          currentIndex: i,
          items: _currentBar.child
              .map(
                (e) => BottomNavigationBarItem(
                  icon: Icon(e.icon),
                  label: e.name,
                ),
              )
              .toList(),
          onTap: (index) {
            setState(() {
              i = index;
            });
          },
        ),
        [
          EcosChartWidget(
            data: Market().baserate,
            duration: Duration(days: 365 * 4),
          ),
          Container(
            child: TreeMapWidget(),
          ),
        ][i],
      ],
    );
  }
}
