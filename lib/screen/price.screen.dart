import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterohddul/chart/pricechart.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

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
  late StockData stock = Stock().fromCode(stockCode);

  _onCodeChanged(String code) {
    codeController.clear();
    stockCode = code;
    stock = Stock().fromCode(stockCode);
    if (stock.valid) {
      setState(() {
        stock.addPrice();
      });
    }
  }

  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _search(v) {
      _visible = true;
    }

    _input() {
      return Section(
        child: TextField(
          style: theme.textTheme.labelLarge,
          controller: codeController,
          onSubmitted: _onCodeChanged,
          onChanged: _search,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.all(8),
          ),
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
        _input(),
        Container(
          height: Screen(context).c,
          decoration: BoxDecoration(color: theme.colorScheme.primary),
          child: FutureBuilder(
            future: stock.addPrice(),
            builder: (BuildContext context, snapshot) => snapshot.hasData
                ? Column(
                    children: [
                      Container(
                        height: Screen(context).ratio.c(.8),
                        child: PriceChartWidget(
                          stock: stock,
                          candles: stock.price!.candles,
                          initialVisibleCandleCount: 100,
                          style: ChartStyle(
                            selectionHighlightColor: theme.colorScheme.tertiary,
                            stockMetaStyle: theme.textTheme.labelLarge!,
                            overlayTextStyle: theme.textTheme.bodySmall!,
                            trendLineStyles: [
                              Paint()..color = Colors.orange,
                              Paint()..color = Colors.blue,
                              Paint()..color = Colors.blue,
                            ],
                            volumeColor: theme.colorScheme.background,
                          ),
                        ),
                      ),
                      Container(
                        height: Screen(context).ratio.c(.2),
                        child: Placeholder(),
                      )
                    ],
                  )
                : Container(
                    width: double.infinity,
                    height: 450,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
          ),
        ),
      ],
    );
  }
}
