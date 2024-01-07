import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterohddul/utils/base/base.dart';
import 'package:flutterohddul/utils/screen.utils.dart';
import 'package:flutterohddul/utils/function/squarify.dart';
import 'package:flutterohddul/utils/colors/colors.convert.dart';

class TreeMapWidget extends StatefulWidget {
  List<num> values;
  List<Widget> children;
  List<Color?>? colors;
  int? take;

  TreeMapWidget({
    super.key,
    required this.values,
    required this.children,
    this.colors,
    this.take,
  });

  @override
  State<TreeMapWidget> createState() => _TreeMapWidgetState();
}

class _TreeMapWidgetState extends State<TreeMapWidget> {
  // bool _children = true;
  List<Rectangle> rectangles = [];

  @override
  Widget build(BuildContext context) {
    if (widget.take != null) {
      var sum = widget.values.sum;
      widget.values =
          widget.values.take(widget.take!).map((e) => e / sum).toList();
    }
    SquarifyData data = SquarifyData(widget.values);
    rectangles = Squarify().squarify(data.data, 0, 0, 1, 1).toList();

    return Section(
      child: Container(
        padding: const EdgeInsets.all(8),
        height: Screen(context).c - 100,
        child: LayoutBuilder(builder: (context, constraints) {
          var w = constraints.maxWidth;
          var h = constraints.maxHeight;
          return Stack(
            children: rectangles.mapIndexed((i, rect) {
              return Positioned(
                left: w * rect.x / dim,
                top: h * rect.y / dim,
                width: w * rect.dx / dim,
                height: h * rect.dy / dim,
                child: Container(
                  decoration: BoxDecoration(
                      color: (widget.colors?[i] ?? Colors.grey).darken(.15)),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      var w = constraints.maxWidth;
                      var h = constraints.maxHeight;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: w * .8,
                              constraints: BoxConstraints(maxHeight: h * .4),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: widget.children[i],
                              ),
                            ),
                            SizedBox(
                              width: w,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${(rect.value! * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}
