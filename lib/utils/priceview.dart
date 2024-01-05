import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceColorView extends StatelessWidget {
  final bool asPercent;
  final dynamic value;
  final TextStyle? style;

  const PriceColorView(
    this.value, {
    super.key,
    this.asPercent = false,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value > 0
          ? '+${asPercent ? value.toStringAsFixed(2) : NumberFormat('#,###,###').format(value)}${asPercent ? '%' : ''}'
          : '${asPercent ? value.toStringAsFixed(2) : NumberFormat('#,###,###').format(value)}${asPercent ? '%' : ''}',
      style: style?.copyWith(
        color: value > 0 ? Colors.green : Colors.red,
      ),
    );
  }
}

class MarketCapView extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const MarketCapView(
    this.value, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value > 1e12
          ? '${(value / 1e12).toStringAsFixed(1)}조'
          : '${(value / 1e8).toStringAsFixed(0)}억',
      style: style,
    );
  }
}

class PriceView extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const PriceView(
    this.value, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat('#,###,###').format(value),
      style: style,
    );
  }
}

class PercentView extends StatelessWidget {
  final double value;
  final TextStyle? style;

  const PercentView(
    this.value, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '(${(value * 100).toStringAsFixed(1)}%)',
      style: style,
    );
  }
}
