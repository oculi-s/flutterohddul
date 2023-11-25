import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/data/user.dart';

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

class PriceColor extends StatelessWidget {
  final bool asPercent;
  final dynamic value;
  final TextStyle style;

  const PriceColor(
    this.value, {
    super.key,
    required this.asPercent,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value > 0
          ? '+${asPercent ? value.toStringAsFixed(2) : value}${asPercent ? '%' : ''}'
          : '${asPercent ? value.toStringAsFixed(2) : value}${asPercent ? '%' : ''}',
      style: style.copyWith(
        color: value > 0 ? Colors.green : Colors.red,
      ),
    );
  }
}

class StockBlock extends StatelessWidget {
  final Stock stock;

  const StockBlock({
    super.key,
    required this.stock,
  });

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
            child: stock.group?.image ?? const Placeholder(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.name!),
                    Text(
                      stock.code!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(stock.currentPrice!.toString()),
                    Row(children: [
                      PriceColor(
                        stock.priceChangeRatio!,
                        asPercent: true,
                        style: theme.textTheme.bodySmall!,
                      ),
                      const SizedBox(width: 10),
                      PriceColor(
                        stock.priceChange,
                        asPercent: false,
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

  stockinfo(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: stock.group?.image ?? const Placeholder(),
          ),
          Text(
            stock.name!,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            stock.currentPrice!.toString(),
            style: theme.textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PriceColor(
                stock.priceChange,
                asPercent: false,
                style: theme.textTheme.bodySmall!,
              ),
              const SizedBox(
                width: 5,
              ),
              PriceColor(
                stock.priceChangeRatio,
                asPercent: true,
                style: theme.textTheme.bodySmall!,
              )
            ],
          )
        ],
      ),
    );
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
              height: MediaQuery.of(context).size.height - 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: theme.canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: stockinfo(context),
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
