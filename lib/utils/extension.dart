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

extension DateExtension on DateTime {
  String asString([String format = 'yyy-MM-dd hh:mm:ss']) =>
      intl.DateFormat(format).format(this);
  int marketType() => (weekday == 0 || weekday == 6
      ? 1
      : (hour * 60 + minute < 539 ? -1 : (hour * 60 + minute > 940 ? 1 : 0)));
  bool canPred() {
    var n = DateTime.now();
    if (weekday == 0) {
      n = DateTime(n.year, n.month, n.day - 2, 15, 30, 0);
    } else if (weekday == 6) {
      n = DateTime(n.year, n.month, n.day - 1, 15, 30, 0);
    } else if (marketType() == -1) {
      n = DateTime(n.year, n.month, n.day - 1, 8, 59, 0);
    } else {
      n = DateTime(n.year, n.month, n.day, 8, 59, 0);
    }
    return isBefore(n);
  }
}

extension IterExtension2d<T> on Iterable<Iterable<T>> {
  List<T> flatten() => expand((e) => e).toList();
}

extension IterExtension1d on Iterable {
  List favsToWidget() =>
      map((e) => e.startsWith('.') ? e.substring(1) : Stock().fromCode(e))
          .toList();
  List<String> widgetToFavs() =>
      map((e) => e is StockData ? e.code : '.$e').toList();
}
