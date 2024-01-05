import 'package:flutter/material.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/priceview.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:fl_chart/fl_chart.dart';

class StockSlide extends StatelessWidget {
  StockData stock;
  StockSlide({required this.stock});

  _sharePie(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      width: Screen(context).w,
      height: 250,
      // Waitfor 사용하면 오류
      child: FutureBuilder(
        future: stock.addShare(),
        builder: (context, snapshot) {
          return snapshot.hasData
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
                              style: theme.textTheme.bodyLarge!.copyWith(
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
                          color: e.date == null
                              ? theme.colorScheme.background.darken(0.1)
                              : stock.group?.color != null
                                  ? stock.group?.color
                                      ?.withAlpha((ratio + 100).toInt())
                                  : e == stock.share.last
                                      ? theme.colorScheme.background
                                      : theme.colorScheme.secondary,
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
                );
        },
      ),
    );
  }

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
            Text(
              title,
              style: theme.textTheme.bodyLarge,
            ),
            value != null
                ? PriceView(
                    value,
                    style: theme.textTheme.bodyMedium,
                  )
                : Container(),
            const SizedBox(width: 3),
            ratio != null
                ? PercentView(
                    ratio,
                    style: theme.textTheme.bodyMedium,
                  )
                : Container()
          ],
        ),
      );
    }

    _earnRow() {
      return Row(
        children: [
          Expanded(
            child: WaitFor(
              future: stock.addEarn(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '시총',
                            style: theme.textTheme.bodyLarge,
                          ),
                          MarketCapView(
                            stock.marketCap,
                            style: theme.textTheme.bodyMedium,
                          )
                        ],
                      ),
                    ),
                    tile(title: 'BPS', value: stock.bps, ratio: stock.bpsRatio),
                    tile(title: 'EPS', value: stock.eps, ratio: stock.epsRatio),
                  ],
                ),
              ),
            ),
          ),
          Anchor(
            href: '/stock/${stock.code}',
            child: Row(
              children: [
                Text('더보기', style: theme.textTheme.bodyMedium),
                Icon(Icons.chevron_right, color: theme.colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            SizedBox(
              width: Screen(context).w,
              height: 300,
              child: const Placeholder(),
            ),
            Column(
              children: [
                const Divider(),
                _earnRow(),
                const Divider(),
                const SizedBox(height: 30),
                _sharePie(context),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      height: Screen(context).c - 10,
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
              color: theme.colorScheme.onPrimary,
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
              color: theme.colorScheme.onPrimaryContainer,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: stock.img,
          ),
          SizedBox(height: 10),
          Text(
            stock.name,
            style: theme.textTheme.headlineSmall,
          ),
          PriceView(
            stock.currentPrice,
            style: theme.textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PriceColorView(
                stock.priceChange,
                asPercent: false,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(
                width: 5,
              ),
              PriceColorView(
                stock.priceChangeRatio,
                asPercent: true,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          _stockInfoinSlide(context)
        ],
      ),
    );
  }
}
