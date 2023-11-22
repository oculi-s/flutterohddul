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
    await Meta().load();
    final jsonData = await Api().read(stock: stock);
    final priceList = List<Candle>.from(jsonData['data']?.map((p) {
      List<dynamic> candleList = [
        DateTime.parse(p['d']).millisecondsSinceEpoch,
        p['o'].toString(),
        p['h'].toString(),
        p['l'].toString(),
        p['c'].toString(),
        p['v'].toString(),
      ];
      return Candle.fromJson(candleList);
    }));
    return PriceData(
      valid: jsonData['valid'],
      stock: stock,
      last: jsonData['last'],
      price: priceList,
    );
  }
}
