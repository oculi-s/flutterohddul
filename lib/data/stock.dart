import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';

class Stock {
  bool valid = true;
  String? code;
  String? name;
  String? marketType;
  int? amount;
  Group? group;
  Induty? induty;
  int? currentPrice, lastPrice, historicalPrice, priceChange;
  int? marketCap;
  int? bps, eps;
  double? bpsRatio, epsRatio;
  double? priceChangeRatio;
  List<Earn>? earn;

  Stock({
    required this.valid,
    this.code,
    this.name,
    this.induty,
    this.group,
    this.marketType,
    this.amount,
    this.currentPrice,
    this.lastPrice,
    this.historicalPrice,
    this.priceChange,
    this.priceChangeRatio,
    this.marketCap,
    this.bps,
    this.eps,
    this.bpsRatio,
    this.epsRatio,
    this.earn,
  });

  factory Stock.fromCode(String code) {
    final data = Meta().meta?.data?.entries.firstWhere((e) {
      return e.key == code || e.value['n'] == code;
    }).value;
    if (data == null) return Stock(valid: false);
    final groupName = Meta().group?.index?[code];
    final indutyCode = Meta().indutyIndex?.data?[code];
    int currentPrice = Meta().price?.data?[code]?['c'] ?? 0;
    int lastPrice = Meta().price?.data?[code]?['p'] ?? 0;
    int historicalPrice = Meta().hist?.data?[code]?['h'] ?? 0;
    int bps = Meta().price?.data?[code]?['bps'] ?? 0;
    int eps = Meta().price?.data?[code]?['eps'] ?? 0;

    return Stock(
      valid: true,
      code: code,
      name: data?['n'],
      amount: data?['a'],
      marketType: data?['t'],
      group: Group.fromName(groupName),
      induty: Induty.fromCode(indutyCode),
      currentPrice: currentPrice,
      lastPrice: lastPrice,
      historicalPrice: historicalPrice,
      priceChange: lastPrice - currentPrice,
      priceChangeRatio: (lastPrice - currentPrice) / lastPrice * 100,
      marketCap: (currentPrice * data['a']).toInt(),
      bps: bps,
      eps: eps,
      bpsRatio: (bps / currentPrice).toDouble(),
      epsRatio: (eps / currentPrice).toDouble(),
    );
  }

  Future<bool> load() async {
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
