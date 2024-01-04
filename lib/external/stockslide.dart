import 'package:flutter/material.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/priceview.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:fl_chart/fl_chart.dart';

class StockSlide extends StatelessWidget {
  StockData stock;
  StockSlide({required this.stock});

  _stockInfoinSlide(BuildContext context) {
    var theme = Theme.of(context);

    tile({required String title, value, ratio}) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Column(
          children: [
            Text(title),
            value != null
                ? PriceView(
                    value,
                    style: theme.textTheme.bodySmall,
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 3),
            ratio != null
                ? PercentView(
                    ratio,
                    style: theme.textTheme.bodySmall,
                  )
                : const SizedBox.shrink()
          ],
        ),
      );
    }

    return [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                width: Screen(context).w,
                height: 300,
                child: const Placeholder(),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: WaitFor(
                      future: stock.addEarn(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Column(
                              children: [
                                const Text('시총'),
                                MarketCapView(
                                  stock.marketCap,
                                  style: theme.textTheme.bodySmall,
                                )
                              ],
                            ),
                          ),
                          tile(
                              title: 'BPS',
                              value: stock.bps,
                              ratio: stock.bpsRatio),
                          tile(
                              title: 'EPS',
                              value: stock.eps,
                              ratio: stock.epsRatio),
                        ],
                      ),
                    ),
                  ),
                  Anchor(
                    href: '/stock/${stock.code}',
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 30),
              SizedBox(
                width: Screen(context).w,
                height: 250,
                // Waitfor 사용하면 오류
                child: FutureBuilder(
                  future: stock.addShare(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? PieChart(
                          PieChartData(
                            sections: List.from(stock.share.map(
                              (e) {
                                double ratio = e.amount / stock.amount * 100;
                                StockData substock = Stock().hasName(e.name);
                                Widget child = Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      e.name,
                                      style:
                                          theme.textTheme.bodyLarge!.copyWith(
                                        color: substock.valid
                                            ? theme.colorScheme.anchor
                                            : null,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${ratio.toStringAsFixed(2)}%',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ],
                                );
                                return PieChartSectionData(
                                  showTitle: false,
                                  badgeWidget: ratio < 5
                                      ? SizedBox.shrink()
                                      : substock.valid
                                          ? Anchor(
                                              stockhref: substock,
                                              child: child,
                                            )
                                          : child,
                                  value: e.amount.toDouble(),
                                  color: theme.colorScheme.secondary,
                                );
                              },
                            )),
                          ),
                        )
                      : Center(
                          child: Container(
                            height: 10,
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              color: theme.colorScheme.background,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      height: Screen(context).h - 10,
      width: Screen(context).w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 25,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: stock.group!.image(),
          ),
          Text(
            stock.name,
            style: theme.textTheme.labelLarge,
          ),
          PriceView(
            stock.currentPrice,
            style: theme.textTheme.labelLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PriceColorView(
                stock.priceChange,
                asPercent: false,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(
                width: 5,
              ),
              PriceColorView(
                stock.priceChangeRatio,
                asPercent: true,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          ..._stockInfoinSlide(context)
        ],
      ),
    );
  }
}
