import 'package:flutter/material.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/priceview.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/data/user.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:pie_chart/pie_chart.dart';

import '../external/stockslide.dart';

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
    defaultList = List.from(
      defaultCode.map(
        (e) => Meta().meta?.data?[e] != null ? Stock().fromCode(e) : e,
      ),
    );
    super.initState();
  }

  Widget data() {
    return Container(
      child: Log().user != null
          ? Column(
              children: List.from(
                Log().user!.favs.map(
                      (e) => e.runtimeType == StockData
                          ? StockBlock(stock: e)
                          : DividerBlock(text: e),
                    ),
              ),
            )
          : Column(
              children: List.from(defaultList.map(
                (stock) => stock.runtimeType == StockData
                    ? StockBlock(stock: stock)
                    : DividerBlock(text: stock),
              )),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Section(
          child: Row(
            children: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
          ),
        ),
        SizedBox(height: 5),
        Section(
          child: Log().user != null
              ? Column(
                  children: List.from(
                    Log().user!.favs.map(
                          (e) => e.runtimeType == StockData
                              ? StockBlock(stock: e)
                              : DividerBlock(text: e),
                        ),
                  ),
                )
              : Column(
                  children: List.from(defaultList.map(
                    (stock) => stock.runtimeType == StockData
                        ? StockBlock(stock: stock)
                        : DividerBlock(text: stock),
                  )),
                ),
        ),
      ],
    );
  }
}

class StockBlock extends StatefulWidget {
  final StockData stock;

  const StockBlock({
    super.key,
    required this.stock,
  });

  @override
  State<StockBlock> createState() => _StockBlockState();
}

class _StockBlockState extends State<StockBlock> {
  late bool _selected;

  @override
  initState() {
    super.initState();
    _selected = false;
  }

  _stockListBarElement(BuildContext context, [bool selected = false]) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            selected ? theme.colorScheme.secondary : theme.colorScheme.primary,
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
              color: theme.colorScheme.background,
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
            child: widget.stock.group!.image(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.stock.name),
                    Text(
                      widget.stock.code,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceView(widget.stock.currentPrice),
                    Row(children: [
                      PriceColorView(
                        widget.stock.priceChange,
                        asPercent: false,
                        style: theme.textTheme.bodySmall!,
                      ),
                      const SizedBox(width: 10),
                      PriceColorView(
                        widget.stock.priceChangeRatio,
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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StockSlide(stock: widget.stock);
          },
        );
      },
      onLongPressStart: (e) {
        setState(() {
          _selected = true;
        });
      },
      onLongPressEnd: (e) {
        setState(() {
          _selected = false;
        });
      },
      onLongPressMoveUpdate: (e) {
        // print(e.globalPosition);
      },
      child: _stockListBarElement(context, _selected),
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
