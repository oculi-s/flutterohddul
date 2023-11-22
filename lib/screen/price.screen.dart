import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/price.dart';

class PriceChart extends StatefulWidget {
  @override
  _PriceChartState createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  List<Candle> candles = [];
  late Stock stock;
  late PriceData priceData;

  @override
  void initState() {
    fetchCandles().then((value) {
      print(value[0].date);
      setState(() {
        candles = value;
      });
    });
    super.initState();
  }

  Future<List<Candle>> fetchCandles() async {
    stock = Stock.fromCode('005930');
    priceData = await PriceData.read(stock);
    return priceData.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Candlesticks(
        candles: candles,
      ),
    );
  }
}
