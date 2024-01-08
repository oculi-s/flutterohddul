import 'dart:math';
import 'package:collection/collection.dart';

class SquarifyData {
  late List<DataPoint> data;
  late double totalSize;
  late double totalArea = 1;

  SquarifyData(List values) {
    data = values.mapIndexed((i, v) => DataPoint(i, v)).toList();
    data.sort((a, b) => b.value.compareTo(a.value));
    totalSize = data.map((e) => e.value).sum;
    data.forEach((p) => p.normalize(totalArea, totalSize));
  }
}

class DataPoint {
  double value;
  late double normalizedValue;
  int id;
  DataPoint(this.id, this.value);

  void normalize(double totalArea, double totalSize) {
    normalizedValue = value * totalArea / totalSize;
  }
}

class Rectangle {
  double x, y, dx, dy;
  double? value;
  int? id;
  Rectangle(this.x, this.y, this.dx, this.dy, this.id, this.value);
  Rectangle.fromDimensions(this.x, this.y, this.dx, this.dy);

  @override
  String toString() {
    return '!SquarifyRect(x: $x, y: $y, dx: $dx, dy: $dy, id: $id, value: $value)\n';
  }
}

class Squarify {
  List<Rectangle> squarify(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    List<Rectangle> rects = [];
    if (values.isEmpty) return rects;
    if (values.length == 1) {
      rects.add(Rectangle(x, y, dx, dy, values[0].id, values[0].value));
      return rects;
    }
    int i = 1;
    while (i < values.length &&
        worstRatio(values.sublist(0, i), dx, dy) >=
            worstRatio(values.sublist(0, i + 1), dx, dy)) {
      i++;
    }
    List<DataPoint> current = values.sublist(0, i);
    List<DataPoint> remaining = values.sublist(i);
    if (dx > 0 && dy > 0) {
      Rectangle currentLeftover = leftover(current, x, y, dx, dy);
      rects.addAll(layout(current, x, y, dx, dy));
      rects.addAll(squarify(remaining, currentLeftover.x, currentLeftover.y,
          currentLeftover.dx, currentLeftover.dy));
    }
    return rects
        .where((e) => !e.dx.isNaN && !e.dy.isNaN && !e.x.isNaN && !e.y.isNaN)
        .toList();
  }

  double worstRatio(List<DataPoint> values, double dx, double dy) {
    double m = 0;
    for (var dataPoint in layout(values, 0, 0, dx, dy)) {
      double rectDx = dataPoint.dx;
      double rectDy = dataPoint.dy;
      m = max(m, max(rectDx / rectDy, rectDy / rectDx));
    }
    return m;
  }

  List<Rectangle> layout(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    if (dx >= dy) return layoutRow(values, x, y, dx, dy);
    return layoutCol(values, x, y, dx, dy);
  }

  List<Rectangle> layoutRow(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    double coveredArea = sumNormalizedValues(values);
    double width = coveredArea / dy;
    return values.map((dataPoint) {
      double rectHeight = dataPoint.normalizedValue / width;
      Rectangle rect =
          Rectangle(x, y, width, rectHeight, dataPoint.id, dataPoint.value);
      y += rectHeight;
      return rect;
    }).toList();
  }

  List<Rectangle> layoutCol(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    double coveredArea = sumNormalizedValues(values);
    double height = coveredArea / dx;
    return values.map((dataPoint) {
      double rectWidth = dataPoint.normalizedValue / height;
      Rectangle rect =
          Rectangle(x, y, rectWidth, height, dataPoint.id, dataPoint.value);
      x += rectWidth;
      return rect;
    }).toList();
  }

  Rectangle leftover(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    if (dx >= dy) return leftoverRow(values, x, y, dx, dy);
    return leftoverCol(values, x, y, dx, dy);
  }

  Rectangle leftoverRow(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    double coveredArea = sumNormalizedValues(values);
    double width = coveredArea / dy;
    return Rectangle.fromDimensions(x + width, y, dx - width, dy);
  }

  Rectangle leftoverCol(
      List<DataPoint> values, double x, double y, double dx, double dy) {
    double coveredArea = sumNormalizedValues(values);
    double height = coveredArea / dx;
    return Rectangle.fromDimensions(x, y + height, dx, dy - height);
  }

  double sumNormalizedValues(List<DataPoint> list) {
    return list.fold(0, (sum, dataPoint) => sum + dataPoint.normalizedValue);
  }
}
