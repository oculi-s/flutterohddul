import 'package:candlesticks/candlesticks.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';

class PriceData {
  final bool valid;
  final Stock stock;
  final int last;
  final List<Candle> price;
  PriceData({
    required this.valid,
    required this.stock,
    required this.last,
    required this.price,
  });

  static Future<PriceData> read(Stock stock) async {
    final jsonData = await Api().read(stock: stock);
    final priceList = List<Candle>.from(jsonData['data']?.map((p) {
      return Candle(
        date: DateTime.parse(p['d']),
        open: p['o'],
        high: p['h'],
        low: p['l'],
        close: p['c'],
        volume: p['v'],
      );
    }));
    return PriceData(
      valid: jsonData['valid'],
      stock: stock,
      last: jsonData['last'],
      price: priceList,
    );
  }
}
