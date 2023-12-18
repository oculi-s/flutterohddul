import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class BarState {
  String name;
  IconData icon;
  List<BarState> child;
  BarState({
    required this.name,
    required this.icon,
    required this.child,
  });
}

class _MarketScreenState extends State<MarketScreen> {
  final _currentBar = [
    BarState(
      name: "세계경제",
      icon: Icons.language_rounded,
      child: [
        BarState(name: "기준금리", icon: Icons.bar_chart_rounded, child: []),
        BarState(name: "CPI", icon: Icons.trending_up_rounded, child: []),
      ],
    ),
    BarState(
      name: "국내경제",
      icon: Icons.flag_rounded,
      child: [
        BarState(name: "시총비중", icon: Icons.pie_chart_rounded, child: []),
      ],
    )
  ];
  final _currentData = [
    Market().baserate,
    Market().cpi,
    // Market().ppi,
  ];
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
    final cdata = _currentData[_currentIndex[0]].data[name];

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

  LineChartBarData? ecosChartElement(String code, EcosData data) {
    if (!_countryName.containsKey(code)) return null;
    final name = _countryName[code];
    if (!data.data.containsKey(name)) return null;
    var cdata = data.data[name]!;
    final raw = data.withPrev! ? cdata.yoy : cdata.data;
    List<FlSpot> spots = raw!
        .where((e) =>
            e.d!.millisecondsSinceEpoch >
            DateTime.now().subtract(duration).millisecondsSinceEpoch)
        .map((e) => FlSpot(
              e.d!.millisecondsSinceEpoch.toDouble(),
              e.v!,
            ))
        .toList();

    if (!_legendVisibility[code]!) {
      return null;
    }

    var color = _countryColor[code] ??
        Color.fromARGB(
          255,
          Random().nextInt(256),
          Random().nextInt(256),
          Random().nextInt(256),
        );

    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        color: color.withOpacity(.1),
        show: true,
      ),
    );
  }

  Widget ecosChart(EcosData data) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(
          bottom: BorderSide(
            width: 1.2,
            color: theme.dividerColor,
          ),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == meta.min || value == meta.max) return Text('');
                    return SideTitleWidget(
                      child: Text(
                        value.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                      axisSide: meta.axisSide,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: duration.inMilliseconds / 5,
                  reservedSize: 30,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final d =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    if (value == meta.min || value == meta.max) return Text('');
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat('yyyy-MM').format(d),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
            lineBarsData: List<LineChartBarData>.from(
              _countryName.keys
                  .map((e) => ecosChartElement(e, data))
                  .where((e) => e != null),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                tooltipBgColor: theme.canvasColor,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  touchedBarSpots.sort((a, b) => a.barIndex - b.barIndex);
                  var res = touchedBarSpots.map((e) {
                    return LineTooltipItem(
                      '●  ',
                      TextStyle(
                        color: _countryColorTooltip.values.toList()[e.barIndex],
                      ),
                      children: [
                        TextSpan(
                          text: _countryNameTooltip.values.toList()[e.barIndex],
                          style: theme.textTheme.bodyMedium,
                        ),
                        const TextSpan(text: '  '),
                        TextSpan(),
                        TextSpan(text: e.y.toString(), style: TextStyle()),
                      ],
                      textAlign: TextAlign.left,
                    );
                  }).toList();
                  return res;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget innerData() {
    var theme = Theme.of(context);
    if (_currentIndex[0] == 0)
      return Column(
        children: [
          Text(
            _currentBar[_currentIndex[0]].child[_currentIndex[1]].name,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.start,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _countryName.keys.map(toggleCountryElement).toList(),
          ),
          SizedBox(height: 5),
          ecosChart(_currentData[_currentIndex[1]]),
        ],
      );
    else
      return Placeholder();
  }

  void _toggleListVisibility() {
    setState(() {
      _isListVisible = !_isListVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_currentIndex);
    var theme = Theme.of(context);
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
                  items: _currentBar
                      .map(
                        (e) => BottomNavigationBarItem(
                          icon: Icon(e.icon),
                          label: e.name,
                        ),
                      )
                      .toList(),
                  onTap: (i) {
                    setState(() {
                      _currentIndex[0] = i;
                      _toggleListVisibility();
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
                height: _isListVisible
                    ? _currentBar[_currentIndex[0]].child.length * 50
                    : 0,
                child: Container(
                  decoration: BoxDecoration(color: theme.canvasColor),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _currentBar[_currentIndex[0]].child.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(
                          _currentBar[_currentIndex[0]].child[i].name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        onTap: () {
                          setState(() {
                            _currentIndex[1] = i;
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
