import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterohddul/data/api.dart';
import 'package:flutterohddul/data/element.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';
import 'package:flutterohddul/utils/screen.utils.dart';

double dim = 1;

class SquarifyData {
  late List<DataPoint> data;
  late double totalSize;
  late double totalArea = dim * dim;
  late int length;

  SquarifyData(List values) {
    data =
        values.map((value) => DataPoint(values.indexOf(value), value)).toList();
    sortDescending();

    totalSize = sumValues(data);
    length = values.length;
    normalize();
  }

  void sortDescending() {
    data.sort((a, b) => b.value.compareTo(a.value));
  }

  void normalize() {
    data.forEach((dataPoint) => dataPoint.normalize(totalArea, totalSize));
  }

  double sumValues(List<DataPoint> list) {
    return list.fold(0, (sum, dataPoint) => sum + dataPoint.value);
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
      rects.add(
          Rectangle(x, y, dx, dy, values[0].id, values[0].normalizedValue));
      return rects;
    }

    int i = 1;
    while (i < values.length &&
        worstRatio(values.sublist(0, i), dx, dy) >=
            worstRatio(values.sublist(0, i + 1), dx, dy)) {
      i += 1;
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
    double _max = 0;
    for (var dataPoint in layout(values, 0, 0, dx, dy)) {
      double rectDx = dataPoint.dx;
      double rectDy = dataPoint.dy;
      _max = max(_max, max(rectDx / rectDy, rectDy / rectDx));
    }
    return _max;
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
      Rectangle rect = Rectangle(
          x, y, width, rectHeight, dataPoint.id, dataPoint.normalizedValue);
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
      Rectangle rect = Rectangle(
          x, y, rectWidth, height, dataPoint.id, dataPoint.normalizedValue);
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

class TreeMapWidget extends StatefulWidget {
  // GroupData? group;
  // IndutyData? induty;

  // TreeMapWidget({this.group, this.induty});

  @override
  State<TreeMapWidget> createState() => _TreeMapWidgetState();
}

class _TreeMapWidgetState extends State<TreeMapWidget> {
  @override
  void initState() {
    super.initState();
    List<double> values = Group()
        .data
        .values
        .map((e) => e.currentPrice!.toDouble())
        .where((e) => e > 20 * 10000 * 10000 * 10000) // 20조 필터링
        .toList();
    SquarifyData data = SquarifyData(values);
    var treedata = Squarify().squarify(data.data, 0, 0, dim, dim).toList();
    Group()
        .data
        .values
        .toList()
        .sublist(0, treedata.length)
        .asMap()
        .forEach((i, e) {
      e.tree = treedata[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            height: Screen(context).c,
            child: LayoutBuilder(builder: (context, constraints) {
              var w = constraints.maxWidth;
              var h = constraints.maxHeight;
              return Stack(
                children:
                    Group().data.values.where((e) => e.tree != null).map((e) {
                  var name = e.name;
                  var rect = e.tree!;
                  return Positioned(
                    left: w * rect.x / dim,
                    top: h * rect.y / dim,
                    width: w * rect.dx / dim,
                    height: h * rect.dy / dim,
                    child: Container(
                      color: (groupColor[name] ?? Colors.grey)
                          .darken()
                          .withOpacity(.8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          var w = constraints.maxWidth;
                          var h = constraints.maxHeight;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: w * 0.6,
                                height: h * 0.2,
                                child: e.image(w * 0.6, h * 0.3),
                              ),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '${(rect.value! * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: h * .2,
                                      color:
                                          groupTextColor[name] ?? Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
          Last(data: Meta().price),
        ],
      ),
    );
  }
}
