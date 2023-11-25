import 'package:flutter/material.dart';
import 'package:flutterohddul/component/priceview.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:pie_chart/pie_chart.dart';

class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<dynamic> defaultList = [];
  List<dynamic> defaultCode = [
    '반도체',
    '005930',
    '000660',
    '이차전지',
    '373220',
    '051910',
    '006400',
    '247540',
    '003670',
    '자동차',
    '005380',
    '000270',
    '003620',
    '철강',
    '005490',
    'IT',
    '035420',
    '035720'
  ];

  @override
  void initState() {
    defaultList = List.from(defaultCode
        .map((e) => Meta().meta?.data?[e] != null ? Stock.fromCode(e) : e));
    super.initState();
  }

  Widget data() {
    return Container(
      child: LoginUser().valid
          ? Column(
              children: List<Widget>.from(
                LoginUser().user.favs!.map(
                      (e) => e.runtimeType == Stock
                          ? StockBlock(stock: e)
                          : DividerBlock(text: e),
                    ),
              ),
            )
          : Column(
              children: List<Widget>.from(defaultList.map(
                (stock) => stock.runtimeType == Stock
                    ? StockBlock(stock: stock)
                    : DividerBlock(text: stock),
              )),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: data(),
        ),
      ),
    );
  }
}

class StockBlock extends StatefulWidget {
  final Stock stock;

  const StockBlock({
    super.key,
    required this.stock,
  });

  @override
  State<StockBlock> createState() => _StockBlockState();
}

class _StockBlockState extends State<StockBlock> {
  stockelement(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(
          bottom: BorderSide(
            width: 1.2,
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: widget.stock.group?.image ?? const Placeholder(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.stock.name!),
                    Text(
                      widget.stock.code!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceView(widget.stock.currentPrice!),
                    Row(children: [
                      PriceColorView(
                        widget.stock.priceChange,
                        asPercent: false,
                        style: theme.textTheme.bodySmall!,
                      ),
                      const SizedBox(width: 10),
                      PriceColorView(
                        widget.stock.priceChangeRatio!,
                        asPercent: true,
                        style: theme.textTheme.bodySmall!,
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  stockmeta(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 25,
            height: 5,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
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
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: widget.stock.group?.image ?? const Placeholder(),
          ),
          Text(
            widget.stock.name!,
            style: theme.textTheme.bodySmall,
          ),
          PriceView(
            widget.stock.currentPrice!,
            style: theme.textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PriceColorView(
                widget.stock.priceChange,
                asPercent: false,
                style: theme.textTheme.bodySmall!,
              ),
              const SizedBox(
                width: 5,
              ),
              PriceColorView(
                widget.stock.priceChangeRatio,
                asPercent: true,
                style: theme.textTheme.bodySmall!,
              ),
            ],
          ),
          ...stockinfo(context)
        ],
      ),
    );
  }

  stockinfo(BuildContext context) {
    var theme = Theme.of(context);

    tile({String? title, value, ratio}) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        child: Column(
          children: [
            Text(title!),
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

    return <Widget>[
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: const Placeholder(),
              ),
              const Divider(),
              Row(
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
                          widget.stock.marketCap!,
                          style: theme.textTheme.bodySmall,
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
              const Divider(),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: const PieChart(
                  dataMap: {"1": 2},
                  chartType: ChartType.ring,
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
  void initState() {
    super.initState();
    widget.stock.load().then((value) {
      print(widget.stock.earn?.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height - 20,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: theme.canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: stockmeta(context),
              ),
            );
          },
        );
      },
      child: stockelement(context),
    );
  }
}

class DividerBlock extends StatelessWidget {
  final String text;

  const DividerBlock({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.canvasColor,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
