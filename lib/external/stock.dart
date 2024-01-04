import 'package:flutter/material.dart';
import 'package:flutterohddul/data/stock.dart';

class StockExternal extends StatelessWidget {
  StockData stock;
  StockExternal({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Text(stock.name);
  }
}
