import 'package:flutterohddul/data/api.dart';
import 'package:intl/intl.dart';

class Market {
  Market._();
  static final Market _instance = Market._();
  factory Market() => _instance;

  EcosData baserate = EcosData(valid: false);
  EcosData cpi = EcosData(valid: false);
  EcosData ppi = EcosData(valid: false);

  bool isDataLoaded() {
    return baserate.valid! && cpi.valid! && ppi.valid!;
  }

  Future<bool> load() async {
    // if (isDataLoaded()) return false;
    await baserate.read('/meta/rate.json', false);
    await cpi.read('/meta/cpi.json');
    await ppi.read('/meta/ppi.json');
    return true;
  }
}

/**
 * [https://ecos.bok.or.kr/api/#/](한국은행 open Api)
 * 
 */
class EcosData {
  late bool? valid;
  late DateTime? last;
  late Map<String, CountryData> data = {};

  EcosData({
    required this.valid,
  });

  Future<bool> read(String url, [bool withPrev = true]) async {
    try {
      final jsonData = await Api().read(url: url);
      final Map raw = jsonData['data'] ?? jsonData;

      int lastTime = int.parse(jsonData['last'].toString());
      DateTime lastDateTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
      valid = true;
      last = lastDateTime;
      data = Map.fromEntries(raw.entries.map(
        (e) {
          final name = e.key;
          final data = e.value;
          return MapEntry(
            name,
            CountryData.from(name, data, withPrev),
          );
        },
      ));
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CountryData {
  String? code, name;
  List<DateAndValue>? data;
  List<DateAndValue> yoy = [];
  List<DateAndValue> mom = [];
  DateTime? minX, maxX;
  int? length;

  CountryData({
    required this.name,
    required this.data,
  });

  static CountryData from(
    String name,
    List<dynamic> raw, [
    bool withPrev = true,
  ]) {
    final data = List<DateAndValue>.from(
      raw.map((e) {
        var d = e['d'] ?? e['date'] ?? e[0] ?? '';
        var v = e['v'] ?? e['value'] ?? e[1] ?? '0';
        return DateAndValue.from(d, v);
      }),
    );
    final res = CountryData(
      name: name,
      data: data,
    );
    res.minX = data.first.d;
    res.maxX = data.last.d;
    res.length = data.length;
    // yoy와 mom데이터를 추가하면
    if (withPrev) {
      res.yoy = List<DateAndValue>.from(data.map(
        (e) {
          final ld = DateTime(e.d!.year - 1, e.d!.month);
          final h = data.firstWhere(
            (dv) => dv.d == ld,
            orElse: () => DateAndValue(d: DateTime.now(), v: 1.0),
          );
          final nv =
              double.parse(((e.v! - h.v!) / h.v! * 100).toStringAsFixed(2));
          return DateAndValue(d: e.d, v: nv);
        },
      ));
      res.mom = List<DateAndValue>.from(data.map(
        (e) {
          final ld = DateTime(e.d!.year, e.d!.month - 1);
          final h = data.firstWhere(
            (dv) => dv.d == ld,
            orElse: () => DateAndValue(d: DateTime.now(), v: 1.0),
          );
          final nv =
              double.parse(((e.v! - h.v!) / h.v! * 100).toStringAsFixed(2));
          return DateAndValue(d: e.d, v: nv);
        },
      ));
    }
    return res;
  }
}

class DateAndValue {
  final DateTime? d;
  final double? v;
  DateAndValue({
    required this.d,
    required this.v,
  });
  static from(String d, String v, [String dtype = "yyyyMM"]) {
    if (dtype == "yyyyMM") {
      d = "${d.substring(0, 4)} ${d.substring(4)}";
      dtype = "${dtype.substring(0, 4)} ${dtype.substring(4)}";
    }
    return DateAndValue(
      d: DateFormat(dtype).parse(d),
      v: double.parse((v)),
    );
  }
}
