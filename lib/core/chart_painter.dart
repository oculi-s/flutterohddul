import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/data/candledata.dart';
import 'package:flutterohddul/data/painter.dart';
import 'package:flutterohddul/data/stock.dart';
import 'package:flutterohddul/utils/extension.dart';

typedef TimeLabelGetter = String Function(int timestamp, int visibleDataCount,
    [bool isTapped]);
typedef PriceLabelGetter = String Function(double price);
typedef OverlayInfoGetter = Map<String, String> Function(Candle candle);

class ChartPainter extends CustomPainter {
  final PainterParams params;
  final TimeLabelGetter getTimeLabel;
  final PriceLabelGetter getPriceLabel;

  ChartPainter({
    required this.params,
    required this.getTimeLabel,
    required this.getPriceLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBasicMeta(canvas, params);
    // Draw time labels (dates) & price labels
    _drawTimeLabels(canvas, params);
    _drawPriceGridAndLabels(canvas, params);

    // Draw prices, volumes & trend line
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    canvas.translate(params.xShift, 0);
    for (int i = 0; i < params.candles.length; i++) {
      _drawSingleDay(canvas, params, i);
    }
    canvas.restore();

    // Draw tap highlight & overlay
    if (params.tapPosition != null) {
      if (params.tapPosition!.dx < params.chartWidth) {
        _drawTapHighlightAndOverlay(canvas, params);
      }
    }
  }

  void _drawBasicMeta(canvas, PainterParams params) {
    double x = 10;
    StockData stock = params.stock;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: params.style.stockMetaStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();
    final nameTp = makeTP(stock.name);
    final codeTp = makeTP(stock.code);
    nameTp.paint(canvas, Offset(x, 8));
    x += nameTp.width + 3;
    codeTp.paint(canvas, Offset(x, 8));
    x += nameTp.width + 3;
  }

  void _drawTimeLabels(canvas, PainterParams params) {
    // We draw one time label per 90 pixels of screen width
    final lineCount = params.chartWidth ~/ 90;
    final gap = 1 / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);
      if (index < params.candles.length) {
        final candle = params.candles[index];
        final visibleDataCount = params.candles.length;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, params.chartHeight),
          Paint()
            ..strokeWidth = 0.3
            ..color = params.style.priceGridLineColor,
        );
        final timeTp = TextPainter(
          text: TextSpan(
            text: getTimeLabel(candle.timestamp, visibleDataCount),
            style: params.style.timeLabelStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

        // Align texts towards vertical bottom
        final topPadding = params.style.timeLabelHeight - timeTp.height;
        timeTp.paint(
          canvas,
          Offset(x - timeTp.width / 2, params.chartHeight + topPadding),
        );
      }
    }
  }

  void _drawPriceGridAndLabels(canvas, PainterParams params) {
    [0.0, 0.225, 0.45, 0.675, 0.9]
        .map((v) => ((params.maxPrice - params.minPrice) * v) + params.minPrice)
        .forEach((y) {
      canvas.drawLine(
        Offset(0, params.fitPrice(y)),
        Offset(params.chartWidth, params.fitPrice(y)),
        Paint()
          ..strokeWidth = 0.3
          ..color = params.style.priceGridLineColor,
      );
      final priceTp = TextPainter(
        text: TextSpan(
          text: getPriceLabel(y),
          style: params.style.priceLabelStyle,
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      priceTp.paint(
          canvas,
          Offset(
            params.chartWidth + 4,
            params.fitPrice(y) - priceTp.height / 2,
          ));
    });
  }

  void _drawSingleDay(canvas, PainterParams params, int i) {
    final candle = params.candles[i];
    final x = i * params.candleWidth;
    final thickWidth = max(params.candleWidth * 0.8, 0.8);
    final thinWidth = max(params.candleWidth * 0.2, 0.2);
    // Draw price bar
    final open = candle.o;
    final close = candle.c;
    final high = candle.h;
    final low = candle.l;
    if (open != null && close != null) {
      final color = open > close
          ? params.style.priceLossColor
          : params.style.priceGainColor;
      canvas.drawLine(
        Offset(x, params.fitPrice(open)),
        Offset(x, params.fitPrice(close)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = color,
      );
      if (high != null && low != null) {
        canvas.drawLine(
          Offset(x, params.fitPrice(high)),
          Offset(x, params.fitPrice(low)),
          Paint()
            ..strokeWidth = thinWidth
            ..color = color,
        );
      }
    }
    // Draw volume bar
    final volume = candle.v;
    if (volume != null) {
      canvas.drawLine(
        Offset(x, params.chartHeight),
        Offset(x, params.fitVolume(volume)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = params.style.volumeColor,
      );
    }
    // Draw trend line
    for (int j = 0; j < candle.line.length; j++) {
      final trendLinePaint = params.style.trendLineStyles.at(j) ?? Paint()
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;

      final pt = candle.line.at(j); // current data point
      final prevPt = params.candles.at(i - 1)?.line.at(j);
      if (pt != null && prevPt != null) {
        canvas.drawLine(
          Offset(x - params.candleWidth, params.fitPrice(prevPt)),
          Offset(x, params.fitPrice(pt)),
          trendLinePaint,
        );
      }
    }
  }

  void _drawTapHighlightAndOverlay(canvas, PainterParams params) {
    final pos = params.tapPosition!;
    final i = params.getCandleIndexFromOffset(pos.dx);
    final candle = params.candles[i];
    canvas.save();
    canvas.translate(params.xShift, 0.0);
    // Draw highlight bar (selection box)
    final paintdash = Paint()
      ..strokeWidth = .2
      ..color = params.style.selectionHighlightColor;

    double dashWidth = 5.0;
    double dashSpace = 10.0;
    double currentY = 0;
    double currentX = 0;
    while (currentY < params.chartHeight) {
      canvas.drawLine(
        Offset(pos.dx, currentY),
        Offset(pos.dx, currentY + dashWidth),
        paintdash,
      );
      currentY += dashSpace;
    }

    while (currentX < params.chartWidth) {
      canvas.drawLine(
        Offset(currentX, pos.dy),
        Offset(currentX + dashWidth, pos.dy),
        paintdash,
      );
      currentX += dashSpace;
    }
    canvas.restore();

    double y = params.fitHeight(pos.dy);
    final priceTp = TextPainter(
      text: TextSpan(
        text: getPriceLabel(y),
        style: params.style.overlayGridTextStyle,
      ),
    )
      ..textDirection = TextDirection.ltr
      ..layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset(
              params.chartWidth - 3,
              pos.dy - priceTp.height / 2,
            ) &
            Size(params.style.priceLabelWidth, 16),
        Radius.circular(0),
      ),
      Paint()..color = params.style.overlayGridBackgroundColor,
    );
    priceTp.paint(
      canvas,
      Offset(
        params.chartWidth + 4,
        pos.dy - priceTp.height / 2,
      ),
    );

    final timeTp = TextPainter(
      text: TextSpan(
        text: getTimeLabel(candle.timestamp, params.candles.length, true),
        style: params.style.overlayGridTextStyle,
      ),
    )
      ..textDirection = TextDirection.ltr
      ..layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset(
              pos.dx - timeTp.width / 2 - 5,
              params.chartHeight,
            ) &
            Size(timeTp.width + 10, 16),
        Radius.circular(0),
      ),
      Paint()..color = params.style.overlayGridBackgroundColor,
    );
    timeTp.paint(
        canvas,
        Offset(
          pos.dx - timeTp.width / 2,
          params.chartHeight,
        ));
    // Draw info pane
    _drawTapOHLCInfo(canvas, params, candle);
  }

  void _drawTapOHLCInfo(canvas, PainterParams params, Candle candle) {
    double diff = (candle.c! - candle.o!) / candle.o! * 100;
    TextStyle priceStyle = diff > 0
        ? params.style.overlayPriceGainStyle
        : params.style.overlayPriceLossStyle;

    TextPainter makeTP(String text, [bool isPrice = false]) => TextPainter(
          text: TextSpan(
            text: text,
            style: isPrice ? priceStyle : params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();
    final _info = {
      "O": candle.o?.asPrice() ?? "-",
      "H": candle.h?.asPrice() ?? "-",
      "L": candle.l?.asPrice() ?? "-",
      "C": candle.c?.asPrice() ?? "-",
    };
    if (_info.isEmpty) return;
    final labels = _info.keys.map((text) => makeTP(text)).toList();
    final values = _info.values.map((text) => makeTP(text, true)).toList();

    double x = 10, y = 30;
    for (int i = 0; i < labels.length; i++) {
      labels[i].paint(canvas, Offset(x, y));
      x += labels[i].width + 2;
      values[i].paint(canvas, Offset(x, y));
      x += values[i].width + 5;
    }
    makeTP('(${diff.asPercent()})', true).paint(canvas, Offset(x, y));

    x = 10;
    y = 50;
    final _infoTrends = {
      "BB": candle.line[0]?.asPrice() ?? "-",
      "하단": candle.line[1]?.asPrice() ?? "-",
      "상단": candle.line[2]?.asPrice() ?? "-",
    };

    TextPainter makeTrendsTP(String text, int i, [bool isPrice = false]) =>
        TextPainter(
          text: TextSpan(
            text: text,
            style: isPrice
                ? params.style.overlayTextStyle
                    .copyWith(color: params.style.trendLineStyles[i].color)
                : params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();
    final labelsTrends = _infoTrends.keys
        .mapIndexed((index, text) => makeTrendsTP(text, index))
        .toList();
    final valuesTrends = _infoTrends.values
        .mapIndexed((index, text) => makeTrendsTP(text, index, true))
        .toList();
    for (int i = 0; i < candle.line.length; i++) {
      labelsTrends[i].paint(canvas, Offset(x, y));
      x += labelsTrends[i].width + 2;
      valuesTrends[i].paint(canvas, Offset(x, y));
      x += valuesTrends[i].width + 5;
    }
  }

  /*
  void _drawTapInfoOverlay(canvas, PainterParams params, Candle candle) {
    final xGap = 8.0;
    final yGap = 4.0;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

    final info = getOverlayInfo(candle);
    if (info.isEmpty) return;
    final labels = info.keys.map((text) => makeTP(text)).toList();
    final values = info.values.map((text) => makeTP(text)).toList();

    final labelsMaxWidth = labels.map((tp) => tp.width).reduce(max);
    final valuesMaxWidth = values.map((tp) => tp.width).reduce(max);
    final panelWidth = labelsMaxWidth + valuesMaxWidth + xGap * 3;
    final panelHeight = max(
          labels.map((tp) => tp.height).reduce((a, b) => a + b),
          values.map((tp) => tp.height).reduce((a, b) => a + b),
        ) +
        yGap * (values.length + 1);

    // Shift the canvas, so the overlay panel can appear near touch position.
    canvas.save();
    final pos = params.tapPosition!;
    final fingerSize = 32.0; // leave some margin around user's finger
    double dx, dy;
    assert(params.size.width >= panelWidth, "Overlay panel is too wide.");
    if (pos.dx <= params.size.width / 2) {
      // If user touches the left-half of the screen,
      // we show the overlay panel near finger touch position, on the right.
      dx = pos.dx + fingerSize;
    } else {
      // Otherwise we show panel on the left of the finger touch position.
      dx = pos.dx - panelWidth - fingerSize;
    }
    dx = dx.clamp(0, params.size.width - panelWidth);
    dy = pos.dy - panelHeight - fingerSize;
    if (dy < 0) dy = 0.0;
    canvas.translate(dx, dy);

    // Draw the background for overlay panel
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & Size(panelWidth, panelHeight),
          Radius.circular(8),
        ),
        Paint()..color = params.style.overlayBackgroundColor);

    // Draw texts
    var y = 0.0;
    for (int i = 0; i < labels.length; i++) {
      y += yGap;
      final rowHeight = max(labels[i].height, values[i].height);
      // Draw labels (left align, vertical center)
      final labelY = y + (rowHeight - labels[i].height) / 2; // vertical center
      labels[i].paint(canvas, Offset(xGap, labelY));

      // Draw values (right align, vertical center)
      final leading = valuesMaxWidth - values[i].width; // right align
      final valueY = y + (rowHeight - values[i].height) / 2; // vertical center
      values[i].paint(
        canvas,
        Offset(labelsMaxWidth + xGap * 2 + leading, valueY),
      );
      y += rowHeight;
    }

    canvas.restore();
  }
  */

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      params.shouldRepaint(oldDelegate.params);
}

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
