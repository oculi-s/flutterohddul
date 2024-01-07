import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  LineChartWidget({
    required this.stock,
    required this.after,
    required this.getter,
    required this.parse,
    this.color,
  });

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  _lineWidget({
    required BuildContext context,
    required double Function(dynamic) getter,
    Color? color,
  }) {
    var theme = Theme.of(context);
    return LineChartBarData(
      isCurved: true,
      spots: widget.stock
          .priceRange(widget.after)
          .map((e) => FlSpot(e.d.ms.toDouble(), getter(e)))
          .toList(),
      dotData: const FlDotData(show: false),
      color: color ??
          groupColor[widget.stock.group?.name] ??
          theme.colorScheme.bull,
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
          leftTitles: AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval:
                  DateTime.now().difference(widget.after).inMilliseconds / 5,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
            tooltipPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            getTooltipItems: (List<LineBarSpot> spots) {
              spots.sort((a, b) => a.barIndex - b.barIndex);
              var _names = ['시가', '상단', '이평', '하단'];
              var res = [
                LineTooltipItem(
                  '',
                  TextStyle(),
                  children: [
                    TextSpan(
                      text: widget.parse(spots[0].y),
                      style: theme.textTheme.bodySmall,
                    ),
                    TextSpan(text: '\n'),
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
