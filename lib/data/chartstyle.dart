import 'package:flutter/material.dart';

class ChartStyle {
  final double volumeHeightFactor;
  final double priceLabelWidth;
  final double timeLabelHeight;

  final TextStyle timeLabelStyle;
  final TextStyle priceLabelStyle;
  final TextStyle overlayTextStyle;

  final Color priceGainColor;
  final Color priceLossColor;
  final Color volumeColor;

  final List<Paint> trendLineStyles;
  final Paint? areaStyle;

  final Color priceGridLineColor;
  final Color selectionHighlightColor;
  final Color overlayBackgroundColor;
  final TextStyle overlayGridTextStyle;
  final Color overlayGridBackgroundColor;
  final TextStyle stockMetaStyle;

  const ChartStyle({
    this.volumeHeightFactor = 0.2,
    this.priceLabelWidth = 48.0,
    this.timeLabelHeight = 24.0,
    this.timeLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.priceLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.overlayTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white,
    ),
    this.overlayGridTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white,
    ),
    this.priceGainColor = const Color(0xff22ab94),
    this.priceLossColor = const Color(0xfff23645),
    this.volumeColor = Colors.grey,
    this.trendLineStyles = const [],
    this.areaStyle,
    this.priceGridLineColor = Colors.grey,
    this.selectionHighlightColor = const Color(0x33757575),
    this.overlayBackgroundColor = const Color(0xEE757575),
    this.overlayGridBackgroundColor = Colors.black,
    this.stockMetaStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  });

  TextStyle get overlayPriceGainStyle =>
      TextStyle(fontSize: 12, color: priceGainColor);
  TextStyle get overlayPriceLossStyle =>
      TextStyle(fontSize: 12, color: priceLossColor);
}
