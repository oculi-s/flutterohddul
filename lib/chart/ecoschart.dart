import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/market.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterohddul/screen/market.screen.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:intl/intl.dart';

class EcosChartWidget extends StatefulWidget {
  final Map<String, String> countryName;
  final Map<String, Color> countryColor;
  final Map<String, bool> legendVisibility;
  final Map<String, String> countryNameTooltip;
  final Map<String, Color> countryColorTooltip;
  final BarState currentBar;
  final Duration duration;

  EcosChartWidget({
    required this.countryName,
    required this.countryColor,
    required this.legendVisibility,
    required this.countryNameTooltip,
    required this.countryColorTooltip,
    required this.currentBar,
    required this.duration,
  });

  @override
  _EcosChartWidgetState createState() => _EcosChartWidgetState();
}

class _EcosChartWidgetState extends State<EcosChartWidget> {
  LineChartBarData? ecosChartElement(String code, EcosData data) {
    if (!widget.countryName.containsKey(code)) return null;
    final name = widget.countryName[code];
    if (!data.data.containsKey(name)) return null;
    var cdata = data.data[name]!;
    final raw = data.withPrev! ? cdata.yoy : cdata.data;
    List<FlSpot> spots = raw!
        .where((e) =>
            e.d!.millisecondsSinceEpoch >
            DateTime.now().subtract(widget.duration).millisecondsSinceEpoch)
        .map((e) => FlSpot(
              e.d!.millisecondsSinceEpoch.toDouble(),
              e.v!,
            ))
        .toList();

    if (!widget.legendVisibility[code]!) {
      return null;
    }

    var color = widget.countryColor[code] ??
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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        border: Border(
          bottom: BorderSide(
            width: 1.2,
            color: theme.dividerColor,
          ),
        ),
      ),
      child: SizedBox(
        width: Screen(context).w,
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
                  interval: widget.duration.inMilliseconds / 5,
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
              widget.countryName.keys
                  .map((e) => ecosChartElement(e, widget.currentBar.data))
                  .where((e) => e != null),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                tooltipBgColor: theme.colorScheme.primary,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  touchedBarSpots.sort((a, b) => a.barIndex - b.barIndex);
                  var res = touchedBarSpots.map((e) {
                    return LineTooltipItem(
                      '●  ',
                      TextStyle(
                        color: widget.countryColorTooltip.values
                            .toList()[e.barIndex],
                      ),
                      children: [
                        TextSpan(
                          text: widget.countryNameTooltip.values
                              .toList()[e.barIndex],
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
}
