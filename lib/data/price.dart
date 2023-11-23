import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/candledata.dart';
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
        timestamp: DateTime.parse(p['d']).millisecondsSinceEpoch,
        open: p['o']?.toDouble(),
        high: p['h']?.toDouble(),
        low: p['l']?.toDouble(),
        close: p['c']?.toDouble(),
        volume: p['v']?.toDouble(),
      );
    })).reversed.toList();
    return PriceData(
      valid: jsonData.isNotEmpty,
      stock: stock,
      last: jsonData['last'],
      price: priceList,
    );
  }
}
