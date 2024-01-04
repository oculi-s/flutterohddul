import 'package:flutter/material.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/external/stockslide.dart';

popStock(BuildContext context, String code) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return StockSlide(stock: Stock().fromCode(code));
    },
  );
}
