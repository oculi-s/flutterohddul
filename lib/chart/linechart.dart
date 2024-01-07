import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatefulWidget {
  final StockData stock;
  final DateTime after;
  final Color? color;
  final double Function(Candle) getter;
  final String Function(double) parse;

  const LineChartWidget({
    super.key,
    required this.stock,
    required this.after,
    required this.getter,
    required this.parse,
    this.color,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval:
                  DateTime.now().difference(widget.after).inMilliseconds / 5,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                if (value == meta.min || value == meta.max) {
                  return const Text('');
                }
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
        borderData: FlBorderData(show: false),
        maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: widget.stock
                .priceRange(widget.after)
                .map((e) => FlSpot(e.d.ms.toDouble(), widget.getter(e)))
                .toList(),
            dotData: const FlDotData(show: false),
            color: widget.color ??
                groupColor[widget.stock.group?.name] ??
                theme.colorScheme.bull,
          )
          // _lineWidget(context: context, getter: (e) => e.c),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            tooltipBgColor: theme.colorScheme.secondary,
            showOnTopOfTheChartBoxArea: true,
            tooltipMargin: 0,
            tooltipPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            getTooltipItems: (List<LineBarSpot> spots) {
              spots.sort((a, b) => a.barIndex - b.barIndex);
              var res = [
                LineTooltipItem(
                  '',
                  const TextStyle(),
                  children: [
                    TextSpan(
                      text: widget.parse(spots[0].y),
                      style: theme.textTheme.bodySmall,
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: DateTime.fromMillisecondsSinceEpoch(
                              spots[0].x.toInt())
                          .asString('yyyy-MM-dd'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  textAlign: TextAlign.center,
                ),
              ];
              return res;
            },
          ),
        ),
      ),
      duration: Duration.zero,
    );
  }
}
