import 'package:flutter/material.dart';
import 'package:flutterohddul/core/router.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/colors/colors.main.dart';
import 'package:flutterohddul/utils/extension.dart';
import 'package:flutterohddul/utils/function/popstock.dart';

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
      builder: (context, snapshot) => snapshot.hasData
          ? child
          : Center(
              child: SizedBox(
                height: 10,
                child: LinearProgressIndicator(
                  minHeight: 10,
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
    );
  }
}
