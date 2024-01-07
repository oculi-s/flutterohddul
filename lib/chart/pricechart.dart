import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/core/chart_painter.dart';
import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/chartstyle.dart';
import 'package:flutterohddul/data/painter.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/extension.dart';

class PriceChartWidget extends StatefulWidget {
  final StockData stock;
  final int minCandleCount, maxCandleCount;
  final ChartStyle style;
  final bool? subChart;

  const PriceChartWidget({
    Key? key,
    required this.stock,
    this.minCandleCount = 90,
    this.maxCandleCount = 250 * 5,
    ChartStyle? style,
    this.subChart,
  })  : style = style ?? const ChartStyle(),
        super(key: key);

  @override
  _PriceChartWidgetState createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  late double _candleWidth;
  late double _startOffset;
  Offset? _tapPosition;

  double? _prevChartWidth;
  late double _prevCandleWidth;
  late double _prevStartOffset;
  late Offset _initialFocalPoint;

  late List<Candle> p;
  @override
  void initState() {
    super.initState();
    p = widget.stock.price;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        final w = size.width - widget.style.priceLabelWidth;
        _handleResize(w);

        final int start = (_startOffset / _candleWidth).floor();
        final int count = (w / _candleWidth).ceil();
        final int end = (start + count).clamp(min(start, p.length), p.length);
        final candlesInRange = p.getRange(start, end).toList();
        if (end < p.length) {
          final nextItem = p[end];
          candlesInRange.add(nextItem);
        }

        final halfCandle = _candleWidth / 2;
        final fractionCandle = _startOffset - start * _candleWidth;
        final xShift = halfCandle - fractionCandle;

        final maxPrice =
            candlesInRange.map((c) => c.h).whereType<double>().reduce(max) *
                1.1;
        final minPrice =
            candlesInRange.map((c) => c.l).whereType<double>().reduce(min) * .9;
        final maxVol = candlesInRange
            .map((c) => c.v)
            .whereType<double>()
            .fold(double.negativeInfinity, max);
        final minVol = candlesInRange
            .map((c) => c.v)
            .whereType<double>()
            .fold(double.infinity, min);

        final chartSize = Size(size.width, size.height * .8);
        final subChartSize = Size(size.width, size.height * .2);
        final child = Column(
          children: [
            CustomPaint(
              size: chartSize,
              painter: ChartPainter(
                params: PainterParams(
                  stock: widget.stock,
                  candles: candlesInRange,
                  style: widget.style,
                  size: chartSize,
                  candleWidth: _candleWidth,
                  startOffset: _startOffset,
                  maxPrice: maxPrice,
                  minPrice: minPrice,
                  maxVol: maxVol,
                  minVol: minVol,
                  xShift: xShift,
                  tapPosition: _tapPosition,
                ),
              ),
            ),
            CustomPaint(
              size: subChartSize,
            )
          ],
        );

        return Listener(
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) {
              final dy = e.scrollDelta.dy;
              if (dy.abs() > 0) {
                _onScaleStart(e.position);
                _onScaleUpdate(dy > 0 ? 0.9 : 1.1, e.position, w);
              }
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            onHover: (e) => setState(() {
              _tapPosition = e.localPosition;
            }),
            child: GestureDetector(
              onTapUp: (e) {
                setState(() => _tapPosition = e.globalPosition);
              },
              onScaleStart: (e) => _onScaleStart(e.localFocalPoint),
              onScaleUpdate: (e) =>
                  _onScaleUpdate(e.scale, e.localFocalPoint, w),
              onScaleEnd: (e) {
                print(e);
              },
              child: child,
            ),
          ),
        );
      },
    );
  }

  _onScaleStart(Offset focalPoint) {
    _prevCandleWidth = _candleWidth;
    _prevStartOffset = _startOffset;
    _initialFocalPoint = focalPoint;
  }

  _onScaleUpdate(double scale, Offset focalPoint, double w) {
    final candleWidth = (_prevCandleWidth * scale)
        .clamp(_getMinCandleWidth(w), _getMaxCandleWidth(w));
    final clampedScale = candleWidth / _prevCandleWidth;
    var startOffset = _prevStartOffset * clampedScale;

    final dx = (focalPoint - _initialFocalPoint).dx * -1;
    startOffset += dx;

    final double prevCount = w / _prevCandleWidth;
    final double currCount = w / candleWidth;
    final zoomAdjustment = (currCount - prevCount) * candleWidth;
    final focalPointFactor = focalPoint.dx / w;
    startOffset -= zoomAdjustment * focalPointFactor;
    // startOffset = startOffset.clamp(0, _getMaxStartOffset(w, candleWidth));

    setState(() {
      _candleWidth = candleWidth;
      _startOffset = startOffset;
      _tapPosition = focalPoint;
    });
  }

  _handleResize(double w) {
    if (w == _prevChartWidth) return;
    if (_prevChartWidth != null) {
      _candleWidth = _candleWidth.clamp(
        _getMinCandleWidth(w),
        _getMaxCandleWidth(w),
      );
      _startOffset = _startOffset.clamp(
        0,
        _getMaxStartOffset(w, _candleWidth),
      );
    } else {
      final count = min(
        p.length,
        widget.minCandleCount,
      );
      _candleWidth = w / count;
      _startOffset = (p.length - count) * _candleWidth;
    }
    _prevChartWidth = w;
  }

  double _getMinCandleWidth(double w) =>
      w / min(widget.maxCandleCount, p.length);
  double _getMaxCandleWidth(double w) =>
      w / min(widget.minCandleCount, p.length);
  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth;
    final start = p.length - count;
    return max(0, candleWidth * start);
  }
}
