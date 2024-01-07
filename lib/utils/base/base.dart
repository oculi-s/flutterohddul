import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/stock.dart';
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
      decoration: BoxDecoration(color: Theme
          .of(context)
          .colorScheme
          .primary),
      child: child,
    );
  }
}

class Last extends StatelessWidget {
  final dynamic data;

  const Last({
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
          style: Theme
              .of(context)
              .textTheme
              .bodySmall,
        ),
        Text(
          ((data.last ??
              DateTime.fromMillisecondsSinceEpoch(data['last']) ??
              DateTime.now()) as DateTime)
              .asString(),
          style: Theme
              .of(context)
              .textTheme
              .bodySmall,
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
  final Future future;
  final Widget child;
  final Widget? other;
  final bool? Function()? condition;

  const WaitFor({
    super.key,
    required this.future,
    required this.child,
    this.other,
    this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData && (condition?.call() ?? true)
            ? child
            : other ??
            Container(
              height: 10,
              constraints: BoxConstraints(
                maxWidth: Screen(context).ratio.w(.5),
              ),
              child: LinearProgressIndicator(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .background,
              ),
            );
      },
    );
  }
}

class RadiusButton extends ElevatedButton {
  final double radius;
  final Color? backgroundColor;

  RadiusButton({
    super.key,
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
          backgroundColor ?? Theme
              .of(context)
              .colorScheme
              .primary),
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
    super.key,
    required this.ratio,
    required this.width,
    this.height = 20,
  })
      : bull = ratio[0] == 0 && ratio[1] == 0
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
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.bull.withOpacity(.8),
              theme.colorScheme.bear.withOpacity(.8),
            ],
            stops: [bull - .1, bear + .1],
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            width: width * bull,
            height: height,
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                const Icon(Icons.thumb_up, size: 15),
                const SizedBox(width: 3),
                Text(
                  ratio[0].toString(),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: width * bear,
            height: height,
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ratio[1].toString(),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(width: 3),
                const Icon(Icons.thumb_down, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
