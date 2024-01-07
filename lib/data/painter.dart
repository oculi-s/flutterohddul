import 'dart:ui';

import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/stock.dart';

class PainterParams {
  final List<Candle> candles;
  final StockData stock;
  final ChartStyle style;
  final Size size;
  final double candleWidth;
  final double startOffset;

  final double maxPrice;
  final double minPrice;
  final double maxVol;
  final double minVol;

  final double xShift;
  final Offset? tapPosition;

  PainterParams({
    required this.stock,
    required this.candles,
    required this.style,
    required this.size,
    required this.candleWidth,
    required this.startOffset,
    required this.maxPrice,
    required this.minPrice,
    required this.maxVol,
    required this.minVol,
    required this.xShift,
    required this.tapPosition,
  });

  double get chartWidth => size.width - style.priceLabelWidth;

  double get chartHeight => size.height - style.timeLabelHeight;

  double get volumeHeight => chartHeight * style.volumeHeightFactor;

  double get priceHeight => chartHeight - volumeHeight;

  double get rangePrice => maxPrice - minPrice;

  int getCandleIndexFromOffset(double x) {
    final adjustedPos = x - xShift + candleWidth / 2;
    final i = adjustedPos ~/ candleWidth;
    return i;
  }

  double fitHeight(double dy) =>
      maxPrice - dy / priceHeight * (maxPrice - minPrice);

  double fitWidth(double dx) => maxVol - dx / chartWidth * (maxVol - minVol);

  double fitPrice(double y) =>
      priceHeight * (maxPrice - y) / (maxPrice - minPrice);

  double fitVolume(double y) {
    const gap = 12; // the gap between price bars and volume bars
    const baseAmount = 2; // display at least "something" for the lowest volume

    if (maxVol == minVol) {
      // Apparently max and min values (in the current visible range, at least)
      // are the same. It's likely they passed in a bunch of zeroes, because
      // they don't have real volume data or don't want to draw volumes.
      assert(() {
        if (style.volumeHeightFactor != 0) {
          print('If you do not want to show volumes, '
              'make sure to set `volumeHeightFactor` (ChartStyle) to zero.');
        }
        return true;
      }());
      // Since they are equal, we just draw all volume bars as half height.
      return priceHeight + volumeHeight / 2;
    }

    final volGridSize = (volumeHeight - baseAmount - gap) / (maxVol - minVol);
    final vol = (y - minVol) * volGridSize;
    return volumeHeight - vol + priceHeight - baseAmount;
  }

  static PainterParams lerp(PainterParams a, PainterParams b, double t) {
    double lerpField(double Function(PainterParams p) getField) =>
        lerpDouble(getField(a), getField(b), t)!;
    return PainterParams(
      stock: b.stock,
      candles: b.candles,
      style: b.style,
      size: b.size,
      candleWidth: b.candleWidth,
      startOffset: b.startOffset,
      maxPrice: lerpField((p) => p.maxPrice),
      minPrice: lerpField((p) => p.minPrice),
      maxVol: lerpField((p) => p.maxVol),
      minVol: lerpField((p) => p.minVol),
      xShift: b.xShift,
      tapPosition: b.tapPosition,
    );
  }

  bool shouldRepaint(PainterParams other) {
    if (candles.length != other.candles.length) return true;

    if (size != other.size ||
        candleWidth != other.candleWidth ||
        startOffset != other.startOffset ||
        xShift != other.xShift) return true;

    if (maxPrice != other.maxPrice ||
        minPrice != other.minPrice ||
        maxVol != other.maxVol ||
        minVol != other.minVol) return true;

    if (tapPosition != other.tapPosition) return true;

    if (style != other.style) return true;

    return false;
  }
}
