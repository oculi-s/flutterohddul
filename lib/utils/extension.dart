import 'package:flutterohddul/data/stock.dart';
import 'package:intl/intl.dart' as intl;

extension DoubleFormatter on double {
  String asPrice() {
    const format = "#,###";
    return intl.NumberFormat(format).format(this);
  }

  String asPercent() {
    final format = this < 100 ? "##0.00" : "#,###";
    final v = intl.NumberFormat(format, "en_US").format(this);
    return "${this >= 0 ? '+' : ''}$v%";
  }

  String asAbbreviated() {
    if (this < 1000) return toStringAsFixed(3);
    if (this >= 1e18) return toStringAsExponential(3);
    final s = intl.NumberFormat("#,###", "en_US").format(this).split(",");
    const suffixes = ["K", "M", "B", "T", "Q"];
    return "${s[0]}.${s[1]}${suffixes[s.length - 2]}";
  }
}

extension DTFormatter on DateTime {
  String asString() => intl.DateFormat('yyyy-MM-dd hh:mm:ss').format(this);
}

extension IterExtension2d<T> on Iterable<Iterable<T>> {
  List<T> flatten() => expand((e) => e).toList();
}

extension IterExtension1d on Iterable {
  List stockOrString() => map((e) => (e is StockData ? e.code : e)).toList();
}
