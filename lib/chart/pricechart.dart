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

  /// The full list of [Candle] to be used for this chart.
  ///
  /// It needs to have at least 3 data points. If data is sufficiently large,
  /// the chart will default to display the most recent 90 data points when
  /// first opened (configurable with [initialVisibleCandleCount] parameter),
  /// and allow users to freely zoom and pan however they like.
  final List<Candle> candles;

  /// The default number of data points to be displayed when the chart is first
  /// opened. The default value is 90. If [Candle] does not have enough data
  /// points, the chart will display all of them.
  final int initialVisibleCandleCount;

  /// If non-null, the style to use for this chart.
  final ChartStyle style;

  /// How the date/time label at the bottom are displayed.
  ///
  /// If null, it defaults to use yyyy-mm format if more than 20 data points
  /// are visible in the current chart window, otherwise it uses mm-dd format.
  final TimeLabelGetter? timeLabel;

  /// How the price labels on the right are displayed.
  ///
  /// If null, it defaults to show 2 digits after the decimal point.
  final PriceLabelGetter? priceLabel;

  /// How the overlay info are displayed, when user touches the chart.
  ///
  /// If null, it defaults to display `date`, `open`, `high`, `low`, `close`
  /// and `volume` fields when user selects a data point in the chart.
  ///
  /// To customize it, pass in a function that returns a Map<String,String>:
  /// ```dart
  /// return {
  ///   "Date": "Customized date string goes here",
  ///   "Open": candle.open?.toStringAsFixed(2) ?? "-",
  ///   "Close": candle.close?.toStringAsFixed(2) ?? "-",
  /// };
  /// ```
  final OverlayInfoGetter? overlayInfo;

  /// An optional event, fired when the user clicks on a candlestick.
  final ValueChanged<Candle>? onTap;

  /// An optional event, fired when user zooms in/out.
  ///
  /// This provides the width of a candlestick at the current zoom level.

  const PriceChartWidget({
    Key? key,
    required this.stock,
    required this.candles,
    this.initialVisibleCandleCount = 90,
    ChartStyle? style,
    this.timeLabel,
    this.priceLabel,
    this.overlayInfo,
    this.onTap,
  })  : style = style ?? const ChartStyle(),
        // assert(candles.length >= 3,
        //     "InteractiveChart requires 3 or more CandleData"),
        // assert(initialVisibleCandleCount >= 3,
        //     "initialVisibleCandleCount must be more 3 or more"),
        super(key: key);

  @override
  _PriceChartWidgetState createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  // The width of an individual bar in the chart.
  late double _candleWidth;

  // The x offset (in px) of current visible chart window,
  // measured against the beginning of the chart.
  // i.e. a value of 0.0 means we are displaying data for the very first day,
  // and a value of 20 * _candleWidth would be skipping the first 20 days.
  late double _startOffset;

  // The position that user is currently tapping, null if user let go.
  Offset? _tapPosition;

  double? _prevChartWidth; // used by _handleResize
  late double _prevCandleWidth;
  late double _prevStartOffset;
  late Offset _initialFocalPoint;
  PainterParams? _prevParams; // used in onTapUp event

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        final w = size.width - widget.style.priceLabelWidth;
        _handleResize(w);

        // Find the visible data range
        final int start = (_startOffset / _candleWidth).floor();
        final int count = (w / _candleWidth).ceil();
        final int end = (start + count)
            .clamp(min(start, widget.candles.length), widget.candles.length);
        final candlesInRange = widget.candles.getRange(start, end).toList();
        if (end < widget.candles.length) {
          // Put in an extra item, since it can become visible when scrolling
          final nextItem = widget.candles[end];
          candlesInRange.add(nextItem);
        }

        // If possible, find neighbouring trend line data,
        // so the chart could draw better-connected lines

        // Find the horizontal shift needed when drawing the candles.
        // First, always shift the chart by half a candle, because when we
        // draw a line using a thick paint, it spreads to both sides.
        // Then, we find out how much "fraction" of a candle is visible, since
        // when users scroll, they don't always stop at exact intervals.
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

        // 애니메이션 끔
        final child = CustomPaint(
          size: size,
          painter: ChartPainter(
            params: PainterParams(
              stock: widget.stock,
              candles: candlesInRange,
              style: widget.style,
              size: size,
              candleWidth: _candleWidth,
              startOffset: _startOffset,
              maxPrice: maxPrice,
              minPrice: minPrice,
              maxVol: maxVol,
              minVol: minVol,
              xShift: xShift,
              tapPosition: _tapPosition,
            ),
            getTimeLabel: widget.timeLabel ?? defaultTimeLabel,
            getPriceLabel: widget.priceLabel ?? defaultPriceLabel,
          ),
        );

        return Listener(
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) {
              final dy = e.scrollDelta.dy;
              if (dy.abs() > 0) {
                _onScaleStart(e.position);
                _onScaleUpdate(
                  dy > 0 ? 0.9 : 1.1,
                  e.position,
                  w,
                );
              }
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            onHover: (e) => setState(() {
              _tapPosition = e.localPosition;
            }),
            child: GestureDetector(
              // Tap and hold to view candle details
              // onTapCancel: () => setState(() => _tapPosition = null),
              onTapUp: (e) {
                // Fire callback event and reset _tapPosition
                // if (widget.onTap != null) _fireOnTapEvent();
                setState(() => _tapPosition = e.globalPosition);
              },
              // Pan and zoom
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
    // Handle zoom
    final candleWidth = (_prevCandleWidth * scale)
        .clamp(_getMinCandleWidth(w), _getMaxCandleWidth(w));
    final clampedScale = candleWidth / _prevCandleWidth;
    var startOffset = _prevStartOffset * clampedScale;
    // Handle pan
    final dx = (focalPoint - _initialFocalPoint).dx * -1;
    startOffset += dx;
    // Adjust pan when zooming
    final double prevCount = w / _prevCandleWidth;
    final double currCount = w / candleWidth;
    final zoomAdjustment = (currCount - prevCount) * candleWidth;
    final focalPointFactor = focalPoint.dx / w;
    startOffset -= zoomAdjustment * focalPointFactor;
    startOffset = startOffset.clamp(0, _getMaxStartOffset(w, candleWidth));
    // Apply changes
    setState(() {
      _candleWidth = candleWidth;
      _startOffset = startOffset;
      _tapPosition = focalPoint;
    });
  }

  _handleResize(double w) {
    if (w == _prevChartWidth) return;
    if (_prevChartWidth != null) {
      // Re-clamp when size changes (e.g. screen rotation)
      _candleWidth = _candleWidth.clamp(
        _getMinCandleWidth(w),
        _getMaxCandleWidth(w),
      );
      _startOffset = _startOffset.clamp(
        0,
        _getMaxStartOffset(w, _candleWidth),
      );
    } else {
      // Default zoom level. Defaults to a 90 day chart, but configurable.
      // If data is shorter, we use the whole range.
      final count = min(
        widget.candles.length,
        widget.initialVisibleCandleCount,
      );
      _candleWidth = w / count;
      // Default show the latest available data, e.g. the most recent 90 days.
      _startOffset = (widget.candles.length - count) * _candleWidth;
    }
    _prevChartWidth = w;
  }

  // The narrowest candle width, i.e. when drawing all available data points.
  double _getMinCandleWidth(double w) => w / widget.candles.length;

  // The widest candle width, e.g. when drawing 14 day chart
  double _getMaxCandleWidth(double w) =>
      w / min(widget.initialVisibleCandleCount, widget.candles.length);

  // Max start offset: how far can we scroll towards the end of the chart
  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth; // visible candles in the window
    final start = widget.candles.length - count;
    return max(0, candleWidth * start);
  }

  String defaultTimeLabel(DateTime d, int visibleDataCount,
      [bool isTapped = false]) {
    final date = d.toIso8601String().split("T").first.split("-");
    if (isTapped) {
      return "${date[0]}-${date[1]}-${date[2]}";
    } else if (visibleDataCount > 20) {
      // If more than 20 data points are visible, we should show year and month.
      return "${date[0]}-${date[1]}"; // yyyy-mm
    } else {
      // Otherwise, we should show month and date.
      return "${date[1]}-${date[2]}"; // mm-dd
    }
  }

  String defaultPriceLabel(double price) => price.asPrice();

  void _fireOnTapEvent() {
    if (_prevParams == null || _tapPosition == null) return;
    final params = _prevParams!;
    final dx = _tapPosition!.dx;
    final selected = params.getCandleIndexFromOffset(dx);
    final candle = params.candles[selected];
    widget.onTap?.call(candle);
  }
}
