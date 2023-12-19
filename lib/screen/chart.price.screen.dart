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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    stock = Stock().fromCode(stockCode);
    if (stock.valid) {
      stock.addPrice().then((e) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  _onCodeChanged(String code) {
    codeController.clear();
    setState(() {
      stockCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final theme = Theme.of(context);

    search() {
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

    change() {
      return IconButton(
        onPressed: () {
          setState(() {
            themeProvider.toggleTheme();
          });
        },
        icon: Icon(
          themeProvider.currentTheme == Brightness.dark
              ? Icons.wb_sunny_sharp
              : Icons.nightlight_round_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: search(),
        actions: [change()],
      ),
      body: isLoading
          ? Container(
              width: double.infinity,
              height: 450,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : PriceChartWidget(
              stock: stock,
              candles: stock.price!.candles,
              initialVisibleCandleCount: 100,
              style: ChartStyle(
                selectionHighlightColor: Colors.black,
              ),
            ),
    );
  }
}
