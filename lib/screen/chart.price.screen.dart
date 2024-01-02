import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterohddul/chart/pricechart.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/main.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({
    super.key,
  });

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  final codeController = TextEditingController();
  String stockCode = '005930';
  late StockData stock;

  @override
  void initState() {
    super.initState();
    stock = Stock().fromCode(stockCode);
  }

  _onCodeChanged(String code) {
    codeController.clear();
    stockCode = code;
    stock = Stock().fromCode(stockCode);
    print(stock.toJson());
    if (stock.valid) {
      setState(() {
        stock.addPrice();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final theme = Theme.of(context);

    _search() {
      return SizedBox(
        width: 100,
        child: TextField(
          style: theme.textTheme.bodyLarge,
          controller: codeController,
          onSubmitted: _onCodeChanged,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(
                r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]')),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _search(),
        FutureBuilder(
          future: stock.addPrice(),
          builder: (BuildContext context, snapshot) => snapshot.hasData
              ? Container(
                  height: 300,
                  decoration: BoxDecoration(color: theme.canvasColor),
                  child: PriceChartWidget(
                    stock: stock,
                    candles: stock.price!.candles,
                    initialVisibleCandleCount: 100,
                    style: ChartStyle(
                      selectionHighlightColor: Colors.black,
                      overlayBackgroundColor: Colors.transparent,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 450,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}
