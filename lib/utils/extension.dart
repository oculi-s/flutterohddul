import 'package:flutterohddul/data/stock.dart';
import 'package:intl/intl.dart' as intl;

extension DoubleFormatter on double {
  String asPrice() {
    const format = "#,###";
    return intl.NumberFormat(format).format(this);
  }

  String asPercent() {
    const format = "##0.00";
    final v = intl.NumberFormat(format, "en_US").format(this);
    return "$v%";
  }

  String asPercentChange() {
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

  double toFixed(digit) {
    return double.parse(toStringAsFixed(digit));
  }
}

extension Dt on DateTime {
  int get ms => millisecondsSinceEpoch;

  String asString([String format = 'yyy-MM-dd hh:mm:ss']) =>
      intl.DateFormat(format).format(this);

  DateTime edit(
      {int? year, int? month, int? day, int? hour, int? minute, int? second}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }

  int marketType() => (weekday == 0 || weekday == 6
      ? 1
      : (hour * 60 + minute < 539 ? -1 : (hour * 60 + minute > 940 ? 1 : 0)));

  bool canPred() {
    return isBefore(shouldnotExistAfter());
  }

  // api의 pred에 대응
  DateTime shouldnotExistAfter() {
    var n = DateTime.now();
    if (weekday == 0 || weekday == 6) {
      // 주말은 금요일 3시반 이후 데이터가 없어야
      n = n.edit(hour: 15, minute: 30, second: 0);
      if (weekday == 0) {
        n = n.edit(day: n.day - 2);
      } else {
        n = n.edit(day: n.day - 1);
      }
    } else {
      // 주중은 당일 9시 이후 데이터가 없어야
      n = n.edit(hour: 8, minute: 59, second: 0);
      if (marketType() == -1) {
        n = n.edit(day: n.day - 1);
      }
    }
    return n;
  }

  DateTime whenToPredNext() {
    var mkt = marketType();
    var n = DateTime.now();
    n = n.edit(hour: 9, minute: 0, second: 0);
    if (weekday == 0) {
      n = n.edit(day: n.day + 1);
    } else if (weekday == 6) {
      n = n.edit(day: n.day + 2);
    } else if (weekday == 5 && 0 <= mkt) {
      n = n.edit(day: n.day + 3);
    } else if (0 <= mkt) {
      n = n.edit(day: n.day + 1);
    }
    return n;
  }

  DateTime whenToScore() {
    var mkt = marketType();
    var n = this;
    n = n.edit(hour: 15, minute: 30, second: 0);
    if (weekday == 0) {
      n = n.edit(day: n.day + 1);
    } else if (weekday == 6) {
      n = n.edit(day: n.day + 2);
    } else if (weekday == 5 && 0 <= mkt) {
      n = n.edit(day: n.day + 3);
    } else if (0 <= mkt) {
      n = n.edit(day: n.day + 1);
    }
    return n;
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

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}

extension MyIterable<E> on Iterable<E> {
  List<E> sortedBy2(Comparable Function(E e) key) =>
      toList()..sort((a, b) => key(a).compareTo(key(b)));
  void sortBy2(Comparable Function(E e) key) {
    (this as List<E>).sort((a, b) => key(a).compareTo(key(b)));
  }
}
