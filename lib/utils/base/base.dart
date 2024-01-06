import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:flutterohddul/utils/function/popstock.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

class Section extends Container {
  Section({
    super.key,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: child,
    );
  }
}

class Last extends StatelessWidget {
  var data;
  Last({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '마지막 업데이트 ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          ((data.last ??
                  DateTime.fromMillisecondsSinceEpoch(data['last']) ??
                  DateTime.now()) as DateTime)
              .asString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class Anchor extends StatelessWidget {
  String href;
  StockData? stockhref;
  Widget child;
  Anchor({
    super.key,
    this.stockhref,
    this.href = '',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (stockhref != null) {
          popStock(context, stockhref!.code);
        } else {
          router.push(href);
        }
      },
      child: child,
    );
  }
}

class WaitFor extends StatelessWidget {
  Future future;
  Widget child;

  WaitFor({
    super.key,
    required this.future,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? child
            : LayoutBuilder(builder: (context, constraints) {
                return Center(
                  child: Container(
                    height: 10,
                    constraints: BoxConstraints(
                      maxWidth: min(constraints.maxWidth * .8,
                          Screen(context).ratio.w(.5)),
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.background,
                    ),
                  ),
                );
              });
      },
    );
  }
}

class RadiusButton extends ElevatedButton {
  final double radius;
  final Color? backgroundColor;

  RadiusButton({
    required BuildContext context,
    required onPressed,
    required child,
    this.radius = 50,
    this.backgroundColor,
  }) : super(
          onPressed: onPressed,
          child: child,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                backgroundColor ?? Theme.of(context).colorScheme.primary),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        );
}

class BullBearBar extends StatelessWidget {
  final List<num> ratio;
  final double width, height;
  final double bull, bear;

  BullBearBar({
    required this.ratio,
    required this.width,
    this.height = 20,
  })  : bull = ratio[0] == 0 && ratio[1] == 0
            ? 0.5
            : (ratio[0]) / (ratio[0] + ratio[1]),
        bear = ratio[0] == 0 && ratio[1] == 0
            ? 0.5
            : (ratio[1]) / (ratio[0] + ratio[1]);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.bull.withOpacity(.8),
              theme.colorScheme.bear.withOpacity(.8),
            ],
            stops: [bull, bear],
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            // color: theme.colorScheme.bull.darken(),
            width: width * bull,
            height: height,
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(Icons.thumb_up, size: 15),
                SizedBox(width: 3),
                Text(
                  ratio[0].toString(),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            // color: theme.colorScheme.bear.darken(.3),
            width: width * bear,
            height: height,
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ratio[1].toString(),
                  style: theme.textTheme.labelLarge,
                ),
                SizedBox(width: 3),
                Icon(Icons.thumb_down, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
