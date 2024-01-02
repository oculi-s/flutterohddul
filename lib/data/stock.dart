import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/element.dart';

class Stock {
  Stock._();
  static final Stock _instance = Stock._();
  factory Stock() => _instance;

  Map<String, StockData> data = {};
  StockData fromCode(String code) {
    final stock = Meta().meta?.data?.entries.firstWhere((e) {
      return e.key == code || e.value['n'] == code;
    });
    if (stock == null) return StockData(valid: false);
    if (data[code] != null) return data[code]!;
    final groupName = Meta().group?.index?[code];
    final indutyCode = Meta().indutyIndex?.data?[code];
    int currentPrice = Meta().price?.data?[code]?['c'] ?? 0;
    int lastPrice = Meta().price?.data?[code]?['p'] ?? 0;
    int historicalPrice = Meta().hist?.data?[code]?['h'] ?? 0;
    int bps = Meta().price?.data?[code]?['bps'] ?? 0;
    int eps = Meta().price?.data?[code]?['eps'] ?? 0;
    print(stock);

    data[code] = StockData(
      valid: true,
      code: stock.key,
      name: stock.value['n'],
      amount: stock.value['a'],
      marketType: stock.value['t'],
      group: Group().data[groupName],
      induty: Induty().data[indutyCode],
      currentPrice: currentPrice,
      lastPrice: lastPrice,
      historicalPrice: historicalPrice,
      bps: bps,
      eps: eps,
    );
    return data[code]!;
  }
}

class StockData {
  bool valid = true;
  String code;
  String name;
  String? marketType;
  int? amount;
  GroupData? group;
  IndutyData? induty;

  int currentPrice, lastPrice, historicalPrice;
  int bps, eps;
  List<Earn>? earn;
  Price? price;

  StockData({
    required this.valid,
    this.code = '',
    this.name = '',
    this.induty,
    this.group,
    this.marketType,
    this.amount,
    this.currentPrice = 0,
    this.lastPrice = 0,
    this.historicalPrice = 0,
    this.bps = 0,
    this.eps = 0,
  });

  int get marketCap => (currentPrice! * amount!).toInt();
  int get priceChange => (lastPrice! - currentPrice!);
  double get priceChangeRatio =>
      (lastPrice! - currentPrice!) / lastPrice! * 100;
  double get bpsRatio => bps! / currentPrice!;
  double get epsRatio => eps! / currentPrice!;

  Future<bool> addPrice() async {
    price = await Price.read(this);
    return true;
  }

  Future<bool> addEarn() async {
    var data = await Api().read(url: '/stock/$code/earnFixed.json');
    earn = List<Earn>.from(data['data']
        .map((e) => Earn.fromJson(e))
        .where((e) => e.valid as bool));
    return true;
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

class Price {
  final bool valid;
  final StockData stock;
  final int last;
  final List<Candle> candles;
  Price({
    required this.valid,
    required this.stock,
    required this.last,
    required this.candles,
  });

  static Future<Price> read(StockData stock) async {
    final jsonData = await Api().read(stock: stock);
    final candles = List<Candle>.from(jsonData['data']?.map((p) {
      return Candle(
        timestamp: DateTime.parse(p['d']).millisecondsSinceEpoch,
        o: p['o']?.toDouble(),
        h: p['h']?.toDouble(),
        l: p['l']?.toDouble(),
        c: p['c']?.toDouble(),
        v: p['v']?.toDouble(),
      );
    })).reversed.toList();
    // [20, 60, 120]

    [60].forEach((period) {
      final ma = Candle.bollinger(candles, period);
      for (int i = 0; i < candles.length; i++) {
        candles[i].trends.addAll(ma[i]);
      }
    });
    return Price(
      valid: jsonData.isNotEmpty,
      stock: stock,
      last: jsonData['last'],
      candles: candles,
    );
  }
}

class Earn {
  bool? valid;
  String? number;
  int? equity, profit, revenue, profitSum;
  DateTime? date;

  Earn({
    this.valid,
    this.number,
    this.equity,
    this.profit,
    this.revenue,
    this.profitSum,
    this.date,
  });

  factory Earn.fromJson(Map json) {
    return Earn(
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

class Share {}
