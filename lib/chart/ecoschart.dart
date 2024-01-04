import 'dart:math';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/base/vars.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/formatter.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:flutterohddul/utils/svgloader.dart';
import 'package:intl/intl.dart';

class EcosChartWidget extends StatefulWidget {
  final EcosData data;
  final Duration duration;

  EcosChartWidget({
    required this.data,
    required this.duration,
  });

  @override
  _EcosChartWidgetState createState() => _EcosChartWidgetState();
}

class _EcosChartWidgetState extends State<EcosChartWidget> {
  final visibleCountries = ["KR", "US"];
  var _visible = {};
  @override
  void initState() {
    super.initState();
    _visible = Map.fromEntries(countryName.keys.map(
      (e) => MapEntry(e, visibleCountries.contains(e)),
    ));
  }

  _ecosChartElement(String code) {
    if (!_visible[code]!) return null;
    if (!countryName.containsKey(code)) return null;
    final name = countryName[code];
    if (!widget.data.data.containsKey(name)) return null;
    var cdata = widget.data.data[name]!;
    final raw = widget.data.withPrev ? cdata.yoy : cdata.data;
    List<FlSpot> spots = raw!
        .where((e) =>
            e.d!.millisecondsSinceEpoch >
            DateTime.now().subtract(widget.duration).millisecondsSinceEpoch)
        .map((e) => FlSpot(
              e.d!.millisecondsSinceEpoch.toDouble(),
              e.v!,
            ))
        .toList();

    var color = countryColor[code] ??
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
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        color: color.withOpacity(.1),
        show: true,
      ),
    );
  }

  Widget _toggleCountryElement(String code) {
    var theme = Theme.of(context);
    final name = countryName[code];
    final cdata = widget.data.data[name];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_visible[code] == true) {
              if (_visible.values.where((e) => e).length == 1) {
                return;
              }
              _visible[code] = false;
            } else {
              _visible[code] = true;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: _visible[code]
                ? theme.colorScheme.primary
                : theme.highlightColor,
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
                  ? SvgLoader.asset(
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
                name ?? '',
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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: countryName.keys.map(_toggleCountryElement).toList(),
        ),
        SizedBox(height: 5),
        Section(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                height: 400,
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
                            if (value == meta.min || value == meta.max)
                              return Text('');
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
                          interval: widget.duration.inMilliseconds / 5,
                          reservedSize: 30,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final d = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            if (value == meta.min || value == meta.max)
                              return Text('');
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
                      border: Border.all(color: theme.dividerColor, width: 1),
                    ),
                    maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
                    lineBarsData: List<LineChartBarData>.from(
                      countryName.keys
                          .map((e) => _ecosChartElement(e))
                          .where((e) => e != null),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        tooltipBgColor: theme.colorScheme.primary,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          touchedBarSpots
                              .sort((a, b) => a.barIndex - b.barIndex);
                          var res = touchedBarSpots.map((e) {
                            return LineTooltipItem(
                              '●  ',
                              TextStyle(
                                color: countryColor.entries
                                    .where((e) => _visible[e.key])
                                    .toList()[e.barIndex]
                                    .value,
                              ),
                              children: [
                                TextSpan(
                                  text: countryName.entries
                                      .where((e) => _visible[e.key])
                                      .toList()[e.barIndex]
                                      .value,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const TextSpan(text: '  '),
                                TextSpan(),
                                TextSpan(
                                    text: e.y.toString(), style: TextStyle()),
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
              Last(data: widget.data),
            ],
          ),
        ),
      ],
    );
  }
}
