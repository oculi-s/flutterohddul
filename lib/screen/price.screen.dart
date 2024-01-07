import 'package:flutter/material.dart';
import 'package:flutterohddul/chart/pricechart.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/function/stocksearch.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

class PriceScreen extends StatefulWidget {
  final String? code;

  const PriceScreen({
    super.key,
    this.code,
  });

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  late StockData stock;

  @override
  void initState() {
    super.initState();
    stock = Stock().fromCode(widget.code ?? '005930');
  }

  final double _customAppbarHeight = 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Section(
          child: SizedBox(
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
          child: SizedBox(
            height: Screen(context).c - _customAppbarHeight,
            child: LayoutBuilder(builder: (context, constraints) {
              return WaitFor(
                future: stock.addPrice(),
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * .8,
                      child: PriceChartWidget(
                        stock: stock,
                        candles: stock.price,
                        initialVisibleCandleCount: 100,
                        style: ChartStyle(
                          selectionHighlightColor: theme.colorScheme.onPrimary,
                          stockMetaStyle: theme.textTheme.labelLarge!,
                          overlayTextStyle: theme.textTheme.bodySmall!,
                          trendLineStyles: [
                            Paint()..color = Colors.blue,
                            Paint()..color = Colors.orange,
                            Paint()..color = Colors.blue,
                          ],
                          volumeColor: theme.colorScheme.background,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * .2,
                      child: const Placeholder(),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
