import 'package:flutter/material.dart';
import 'package:flutterohddul/data/stock.dart';

class StockExternal extends StatefulWidget {
  String? code;
  StockExternal({
    super.key,
    required this.code,
  });

  @override
  State<StockExternal> createState() => _StockExternalState();
}

class _StockExternalState extends State<StockExternal> {
  late StockData stock;

  @override
  void initState() {
    super.initState();
    stock = Stock().fromCode(widget.code ?? '005930');
  }

  @override
  Widget build(BuildContext context) {
    return Text(stock.name);
  }
}
