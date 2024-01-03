import 'dart:math';

class Candle {
  final int timestamp;
  final double? o, h, l, c, v;

  List<double?> line;

  Candle({
    required this.timestamp,
    required this.o,
    required this.c,
    required this.v,
    this.h,
    this.l,
  }) : line = [];
}

void addma(List<Candle> candles, [int period = 7]) {
  if (candles.length < period * 2) return;

  final List<List<double?>> result = [[]];
  final firstPeriod = candles.take(period).map((d) => d.c).whereType<double>();
  double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;
  result.addAll(List.filled(period, [null]));

  for (int i = period; i < candles.length; i++) {
    final curr = candles[i].c;
    final prev = candles[i - period].c;
    if (curr != null && prev != null) {
      ma = (ma * period + curr - prev) / period;
      result.add([ma]);
    } else {
      result.add([null]);
    }
  }
  for (int i = 0; i < candles.length; i++) {
    candles[i].line.addAll(result[i]);
  }
}

void addbollinger(List<Candle> candles, [int period = 7]) {
  if (candles.length < period * 2) return;

  final List<List<double?>> result = [];
  final unit = candles.take(period).map((d) => d.c).whereType<double>();
  double ma = unit.reduce((a, b) => a + b) / period;
  double vari =
      unit.map((p) => pow(p - ma, 2)).reduce((a, b) => a + b) / period;
  double std;
  result.addAll(List.filled(period, [null]));

  for (int i = period; i < candles.length; i++) {
    final curr = candles[i].c;
    final prev = candles[i - period].c;
    if (curr != null && prev != null) {
      double maOld = ma;
      ma = (maOld * period + curr - prev) / period;
      vari =
          (vari * period + pow(curr - ma, 2) - pow(prev - maOld, 2)) / period;
      std = sqrt(vari);
      result.add([ma, ma - 2 * std, ma + 2 * std]);
    } else {
      result.add([null]);
    }
  }
  for (int i = 0; i < candles.length; i++) {
    candles[i].line.addAll(result[i]);
  }
}
