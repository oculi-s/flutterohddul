import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/chart/ecoschart.dart';
import 'package:flutterohddul/chart/treemap.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:intl/intl.dart';

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
  final _countryName = {
    "KR": "한국",
    "US": "미국",
    "CN": "중국",
    "JP": "일본",
    "GB": "영국",
    "IN": "인도",
    "CA": "캐나다",
    "RU": "러시아",
    "EUR": "유로존",
  };
  final _countryColor = {
    "KR": Color(0xffcd313a),
    "US": Color(0xff002664),
    "CN": Color(0xffee1c25),
    "JP": Color(0xff000000),
    "IN": Color(0xffff671f),
    "GB": Color(0xff012169),
    "CA": Color(0xffda291c),
    "RU": Color(0xff0039a6),
    "EUR": Color(0xff0011ff),
  };
  final List<String> visibleCountries = ["KR", "US"];
  late Map<String, String> _countryNameTooltip;
  late Map<String, Color> _countryColorTooltip;
  late Map<String, bool> _legendVisibility;

  final _currentIndex = [0, 0];
  final duration = Duration(days: 365 * 4);
  bool _isListVisible = false;

  @override
  void initState() {
    super.initState();
    _legendVisibility = Map.fromEntries(
      _countryName.keys.map(
        (e) => MapEntry(e, visibleCountries.contains(e)),
      ),
    );
    _countryNameTooltip = Map.fromEntries(
      visibleCountries.map(
        (e) => MapEntry(e, _countryName[e]!),
      ),
    );
    _countryColorTooltip = Map.fromEntries(
      visibleCountries.map(
        (e) => MapEntry(e, _countryColor[e]!),
      ),
    );
  }

  Widget toggleCountryElement(String code) {
    var theme = Theme.of(context);
    final name = _countryName[code];
    final cdata = _currentBar.from(_currentIndex).data.data[name];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_legendVisibility[code] == true) {
              if (_legendVisibility.values.where((e) => e).length == 1) {
                return;
              }
              _legendVisibility[code] = false;
              _countryNameTooltip.remove(code);
              _countryColorTooltip.remove(code);
            } else {
              _legendVisibility[code] = true;
              _countryNameTooltip[code] = _countryName[code]!;
              _countryColorTooltip[code] = _countryColor[code]!;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: !_legendVisibility[code]!
                ? theme.highlightColor
                : theme.canvasColor,
            border: Border(
              bottom: BorderSide(
                width: 1.2,
                color: theme.dividerColor,
              ),
            ),
          ),
          child: Column(
            children: [
              code == 'EUR'
                  ? SvgPicture.asset(
                      'assets/img/eur.svg',
                      height: 20,
                      width: 20,
                    )
                  : CountryFlag.fromCountryCode(
                      code,
                      height: 20,
                      width: 20,
                    ),
              Text(
                name!,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                (cdata?.withPrev ?? false ? cdata?.yoy : cdata?.data)
                        ?.last
                        .v
                        .toString() ??
                    '-',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget innerData() {
    var bar = _currentBar.from(_currentIndex);
    var theme = Theme.of(context);
    if (_currentIndex[0] == 0) {
      return Column(
        children: [
          Text(
            bar.name,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.start,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _countryName.keys.map(toggleCountryElement).toList(),
          ),
          SizedBox(height: 5),
          EcosChartWidget(
            currentBar: bar,
            countryColor: _countryColor,
            countryColorTooltip: _countryColorTooltip,
            countryName: _countryName,
            countryNameTooltip: _countryNameTooltip,
            duration: duration,
            legendVisibility: _legendVisibility,
          ),
        ],
      );
    } else if (_currentIndex[0] == 1) {
      return Container(
        child: TreeMapWidget(),
      );
    }
    return Placeholder();
  }

  void _toggleListVisibility() {
    setState(() {
      _isListVisible = !_isListVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    int i = _currentIndex[0];
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Positioned(
                width: MediaQuery.of(context).size.width,
                top: 0,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex[0],
                  items: _currentBar.child
                      .map(
                        (e) => BottomNavigationBarItem(
                          icon: Icon(e.icon),
                          label: e.name,
                        ),
                      )
                      .toList(),
                  onTap: (i) {
                    setState(() {
                      if (_currentIndex[0] == i) {
                        _toggleListVisibility();
                      }
                      _currentIndex[0] = i;
                      _currentIndex[1] = 0;
                    });
                  },
                )),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: 60,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                child: innerData(),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              left: 0,
              top: 60,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height:
                    _isListVisible ? _currentBar.child[i].child.length * 50 : 0,
                child: Container(
                  decoration: BoxDecoration(color: theme.canvasColor),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _currentBar.child[i].child.length,
                    itemBuilder: (ctx, j) {
                      return ListTile(
                        title: Text(
                          _currentBar.from([i, j]).name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        onTap: () {
                          setState(() {
                            _currentIndex[1] = j;
                            _toggleListVisibility();
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
