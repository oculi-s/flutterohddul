import 'dart:math';

class Candle {
  final int timestamp;
  final double? o, h, l, c, v;

  List<double?> trends;

  Candle({
    required this.timestamp,
    required this.o,
    required this.c,
    required this.v,
    this.h,
    this.l,
    List<double?>? trends,
  }) : trends = [];

  static List<List<double?>> ma(List<Candle> data, [int period = 7]) {
    if (data.length < period * 2) return List.filled(data.length, [null]);

    final List<List<double?>> result = [[]];
    final firstPeriod = data.take(period).map((d) => d.c).whereType<double>();
    double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;
    result.addAll(List.filled(period, [null]));

    for (int i = period; i < data.length; i++) {
      final curr = data[i].c;
      final prev = data[i - period].c;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        result.add([ma]);
      } else {
        result.add([null]);
      }
    }
    return result;
  }

  static List<List<double?>> bollinger(List<Candle> data, [int period = 7]) {
    if (data.length < period * 2) return List.filled(data.length, [null]);

    final List<List<double?>> result = [];
    final unit = data.take(period).map((d) => d.c).whereType<double>();
    double ma = unit.reduce((a, b) => a + b) / period;
    double vari =
        unit.map((p) => pow(p - ma, 2)).reduce((a, b) => a + b) / period;
    double std;
    result.addAll(List.filled(period, [null]));

    for (int i = period; i < data.length; i++) {
      final curr = data[i].c;
      final prev = data[i - period].c;
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
    return result;
  }
}

class Trend {}
