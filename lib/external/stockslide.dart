import 'package:flutter/material.dart';
import 'package:flutterohddul/chart/linechart.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:flutterohddul/utils/priceview.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:fl_chart/fl_chart.dart';

class StockSlide extends StatefulWidget {
  final StockData stock;
  const StockSlide({super.key, required this.stock});

  @override
  State<StockSlide> createState() => _StockSlideState();
}

class _StockSlideState extends State<StockSlide> {
  int _days = 365;

  _topslidebar(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      width: 25,
      height: 5,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
      ),
    );
  }

  _sharePie(BuildContext context) {
    var theme = Theme.of(context);
    // Waitfor 오류
    return FutureBuilder(
      future: widget.stock.addShare(),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 30,
                ),
              )
            : SizedBox(
                width: Screen(context).w,
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: List.from(widget.stock.share.map(
                      (e) {
                        double ratio = e.amount / widget.stock.amount * 100;
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
                              ? const SizedBox.shrink()
                              : substock.valid
                                  ? Anchor(
                                      stockhref: substock,
                                      child: child,
                                    )
                                  : child,
                          value: e.amount.toDouble(),
                          color: e.date == null
                              ? theme.colorScheme.background.darken(0.1)
                              : widget.stock.group?.color != null
                                  ? widget.stock.group?.color
                                      ?.withAlpha((ratio + 100).toInt())
                                  : e == widget.stock.share.last
                                      ? theme.colorScheme.background
                                      : theme.colorScheme.secondary,
                        );
                      },
                    )),
                  ),
                ),
              );
      },
    );
  }

  _earn(BuildContext context) {
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

    return Row(
      children: [
        Expanded(
          child: WaitFor(
            future: widget.stock.addEarn(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Column(
                      children: [
                        Text('시총', style: theme.textTheme.bodyLarge),
                        MarketCapView(
                          widget.stock.marketCap,
                          style: theme.textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                  tile(
                      title: 'BPS',
                      value: widget.stock.bps,
                      ratio: widget.stock.bpsRatio),
                  tile(
                      title: 'EPS',
                      value: widget.stock.eps,
                      ratio: widget.stock.epsRatio),
                ],
              ),
            ),
          ),
        ),
        Anchor(
          href: '/stock/${widget.stock.code}',
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

  _priceLine(BuildContext context) {
    var theme = Theme.of(context);

    button(text, days) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _days = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: days == _days ? theme.dividerColor : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 240,
          width: Screen(context).w,
          child: WaitFor(
            future: widget.stock.addPrice(),
            other: const CircularProgressIndicator(),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: LineChartWidget(
                stock: widget.stock,
                after: DateTime.now().subtract(Duration(days: _days)),
                getter: (e) => e.c,
                parse: (e) => e.asPrice(),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  button("3M", 90),
                  button("6M", 180),
                  button("1Y", 365),
                  button("5Y", 365 * 5),
                  button("전체", 365 * 20),
                ],
              ),
              IconButton(
                onPressed: () {
                  router.go('/chart/${widget.stock.code}');
                },
                icon: const Icon(Icons.fullscreen),
              )
            ],
          ),
        ),
      ],
    );
  }

  _meta(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      children: [
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
          child: widget.stock.img,
        ),
        const SizedBox(height: 10),
        Text(
          widget.stock.name,
          style: theme.textTheme.bodyLarge,
        ),
        PriceView(
          widget.stock.currentPrice,
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PriceColorView(
              widget.stock.priceChange,
              asPercent: false,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(
              width: 5,
            ),
            PriceColorView(
              widget.stock.priceChangeRatio,
              asPercent: true,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      // 추가로 swipe시 다른 slide보이도록
      // onHorizontalDragUpdate: (details) {
      //   // Note: Sensitivity is integer used when you don't want to mess up vertical drag
      //   int sensitivity = 8;
      //   if (details.delta.dx > sensitivity) {
      //     print('right');
      //   } else if (details.delta.dx < -sensitivity) {
      //     print('left');
      //   }
      // },
      child: Container(
        height: Screen(context).c,
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
            _topslidebar(context),
            const SizedBox(height: 20),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          BullBearBar(
                            ratio: [widget.stock.upall, widget.stock.downall],
                            width: 90,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.description_outlined),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.edit_square,
                                size: 18,
                                weight: .5,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                _meta(context),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Divider(),
                    _priceLine(context),
                    const Divider(),
                    _earn(context),
                    const Divider(),
                    const SizedBox(height: 30),
                    _sharePie(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
