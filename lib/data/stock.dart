import 'package:collection/collection.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/prediction.dart';
import 'package:flutterohddul/utils/svgloader.dart';

class Stock {
  Stock._();
  static final Stock _instance = Stock._();
  factory Stock() => _instance;

  Map<String, StockData> data = {};

  List<StockData> filter(String v) {
    v = v.toLowerCase();
    if (data.containsKey(v)) return [data[v]!];
    final res = Meta()
        .meta
        ?.data
        ?.entries
        .where((e) =>
            (e.value['n'] as String).toLowerCase().contains(v) ||
            e.key.contains(v))
        .map((e) => fromCode(e.key))
        .take(10)
        .toList();
    return res ?? [];
  }

  bool hasCode(String code) {
    return Meta().meta?.data?[code] != null;
  }

  StockData fromCode(String code) {
    final stock = Meta().meta?.data?.entries.firstWhereOrNull((e) {
      return e.key == code || e.value['n'] == code;
    });
    if (stock == null) return StockData(valid: false);
    if (data[code] is StockData) return data[code]!;
    final groupName = Meta().group?.index?[code];
    final indutyCode = Meta().indutyIndex?.data?[code];
    int currentPrice = Meta().price?.data?[code]?['c'] ?? 0;
    int lastPrice = Meta().price?.data?[code]?['p'] ?? 0;
    int historicalPrice = Meta().hist?.data?[code]?['h'] ?? 0;
    int bps = Meta().price?.data?[code]?['bps'] ?? 0;
    int eps = Meta().price?.data?[code]?['eps'] ?? 0;

    data[code] = StockData(
      valid: true,
      code: stock.key,
      name: stock.value['n'] ?? '',
      amount: stock.value['a'] ?? 0,
      marketType: stock.value['t'],
      group: Group().fromName(groupName),
      induty: Induty().fromCode(indutyCode),
      currentPrice: currentPrice,
      lastPrice: lastPrice,
      historicalPrice: historicalPrice,
      bps: bps,
      eps: eps,
    );
    return data[code]!;
  }

  StockData hasName(String name) {
    final stock = Meta().meta?.data?.entries.firstWhereOrNull((e) {
      return e.value['n'] == name;
    });
    if (stock == null) return StockData(valid: false);
    return Stock().fromCode(stock.key);
  }
}

class StockData {
  bool valid = true;
  String code;
  String name;
  String? marketType;
  int amount;
  GroupData? group;
  IndutyData? induty;

  int currentPrice, lastPrice, historicalPrice;
  int bps, eps;
  List<EarnItem> earn = [];
  List<ShareItem> share = [];
  List<PredQueueItem> pred = [];
  List<Candle> price = [];

  get img => group != null ? group?.image() : SvgLoader.asset('assets/svg.svg');

  StockData({
    required this.valid,
    this.code = '',
    this.name = '',
    this.induty,
    this.group,
    this.marketType,
    this.amount = 0,
    this.currentPrice = 0,
    this.lastPrice = 0,
    this.historicalPrice = 0,
    this.bps = 0,
    this.eps = 0,
  });

  int get marketCap => (currentPrice * amount).toInt();
  int get priceChange => (currentPrice - lastPrice);
  double get priceChangeRatio => priceChange / lastPrice * 100;
  double get bpsRatio => bps / currentPrice;
  double get epsRatio => eps / currentPrice;
  double get tick => currentPrice >= 1000000 ? 5 : 1;

  int get up => Pred().count.findQueue(up: true, code: code);
  int get down => Pred().count.findQueue(up: false, code: code);
  int get upall => Pred().count.findData(up: true, code: code) + up;
  int get downall => Pred().count.findData(up: false, code: code) + down;

  List<Candle> priceRange(DateTime after) =>
      price.where((e) => e.d.isAfter(after)).toList();

  Future<bool> addPrice() async {
    if (price.isNotEmpty) return true;
    try {
      var data = await Api().read(stock: this);
      price = List<Candle>.from((data['data'] ?? []).map((p) => Candle(
            d: DateTime.parse(p['d']),
            o: p['o']?.toDouble(),
            h: p['h']?.toDouble(),
            l: p['l']?.toDouble(),
            c: p['c']?.toDouble(),
            v: p['v']?.toDouble(),
          ))).reversed.toList();
      addbollinger(price, 60);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addEarn() async {
    if (earn.isNotEmpty) return true;
    try {
      var data = await Api().read(url: '/stock/$code/earnFixed.json');
      earn = List<EarnItem>.from(data['data'].map((e) => EarnItem.fromJson(e)))
          .where((e) => e.valid)
          .toList()
          .sortedBy((e) => e.date!);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addShare() async {
    if (share.isNotEmpty) return true;
    try {
      var data = await Api().read(url: '/stock/$code/shareFixed.json');
      share =
          List<ShareItem>.from(data['data'].map((e) => ShareItem.fromJson(e)));
      share.sortByCompare((a) => a.amount, (a, b) => a - b);
      int rest = amount - share.map((e) => e.amount).sum;
      if (rest > 0) {
        share.add(
            ShareItem(amount: rest, date: null, name: '데이터없음', number: ''));
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'amount': amount,
      'marketType': marketType,
      'group': group?.toJson(),
      'induty': induty?.toJson(),
    };
  }
}

class EarnItem {
  bool valid;
  String number;
  int equity, profit, revenue, profitSum;
  DateTime? date;

  EarnItem({
    this.valid = false,
    this.number = '',
    this.equity = 0,
    this.profit = 0,
    this.revenue = 0,
    this.profitSum = 0,
    this.date,
  });

  factory EarnItem.fromJson(Map json) {
    return EarnItem(
      number: json['no'],
      valid: json['data'],
      date: DateTime.parse(json['date']),
      equity: json['equity'],
      profit: json['profit'],
      revenue: json['sum']?['revenue'],
      profitSum: json['sum']?['profit'],
    );
  }
}

class ShareItem {
  String number;
  String name;
  int amount;
  DateTime? date;
  ShareItem({
    this.number = '',
    this.name = '',
    this.amount = 0,
    this.date,
  });

  factory ShareItem.fromJson(Map json) {
    return ShareItem(
      number: json['no'],
      name: json['name'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}
