import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MarketScreen extends StatefulWidget {
  final Key? key;

  MarketScreen({this.key}) : super(key: key);
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  var countryName = {
    "kr": "한국",
    "us": "미국",
    // "jp": "일본",
    // "cn": "중국",
    "eur": "유로 지역",
  };

  @override
  void initState() {
    super.initState();
    // isLoading = true;
  }

  rateBarElement(BuildContext contest, String code) {
    var theme = Theme.of(context);
    final name = countryName[code];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(
          bottom: BorderSide(
            width: 1.2,
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          CountryFlag.fromCountryCode(
            code,
            height: 20,
            width: 20,
          ),
          Text('기준금리'),
          Text(Market().baserate.data?[name]?.data?.last.v.toString() ?? ''),
          Text('CPI'),
          Text(Market().cpi.data?[name]?.yoy?.last.v.toString() ?? ''),
          Text('PPI'),
          Text(Market().ppi.data?[name]?.yoy?.last.v.toString() ?? ''),
        ],
      ),
    );
  }

  lineCharts(String code, EcosData data) {
    if (!countryName.containsKey(code)) return null;
    final name = countryName[code];
    if (!data.data.containsKey(name)) return null;
    final cdata = data.data[name];
    List<FlSpot> spots = List<FlSpot>.from(
      cdata!.yoy
          .where(
            (e) =>
                e.d!.millisecondsSinceEpoch >
                DateTime.now()
                    .subtract(Duration(days: 365 * 4))
                    .millisecondsSinceEpoch,
          )
          .map(
            (e) => FlSpot(
              e.d!.millisecondsSinceEpoch.toDouble(),
              e.v!,
            ),
          ),
    );
    return LineChartBarData(
      spots: spots,
      // isCurved: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      barWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ...countryName.keys.map(
            (e) => rateBarElement(context, e),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .9,
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles()),
                  topTitles: AxisTitles(sideTitles: SideTitles()),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            Duration(days: 365 ~/ 2).inMilliseconds.toDouble(),
                        reservedSize: 100,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return RotatedBox(
                            quarterTurns: 1,
                            child: SizedBox(
                              width: 100,
                              height: 20,
                              child: Text(DateFormat('yyyy-MM-dd').format(d)),
                            ),
                          );
                        }),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                // maxY: 6,
                // minY: -1,
                // minX: Market()
                //     .cpi
                //     .data
                //     .values
                //     .first
                //     .minX!
                //     .millisecondsSinceEpoch
                //     .toDouble(),
                maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
                lineBarsData: List<LineChartBarData>.from(
                  countryName.keys
                      .map((e) => lineCharts(e, Market().cpi))
                      .where((e) => e != null)
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
