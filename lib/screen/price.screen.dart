import 'package:flutter/material.dart';
import 'package:flutterohddul/chart/pricechart.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/function/stocksearch.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({
    super.key,
  });

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  late StockData stock;

  @override
  void initState() {
    super.initState();
    stock = Stock().fromCode('005930');
  }

  bool _visible = false;
  double _customAppbarHeight = 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Section(
          child: Container(
            height: _customAppbarHeight,
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SearchResultDialog(
                      onPressItem: (v) {
                        setState(() {
                          stock = Stock().fromCode(v);
                        });
                      },
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    '${stock.name} ${stock.code}',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Section(
          child: Container(
            height: Screen(context).c - _customAppbarHeight,
            child: LayoutBuilder(builder: (context, constraints) {
              return FutureBuilder(
                future: stock.addPrice(),
                builder: (context, snapshot) => (stock.price?.candles != null &&
                        stock.price!.candles.isNotEmpty)
                    ? Column(
                        children: [
                          Container(
                            height: constraints.maxHeight * .8,
                            child: PriceChartWidget(
                              stock: stock,
                              candles: stock.price?.candles ?? [],
                              initialVisibleCandleCount: 100,
                              style: ChartStyle(
                                selectionHighlightColor:
                                    theme.colorScheme.onPrimary,
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
                            height: constraints.maxHeight * .2,
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
              );
            }),
          ),
        ),
      ],
    );
  }
}
