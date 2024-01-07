import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<Widget> children;
  final TextStyle? style;

  const BulletList({
    super.key,
    required this.children,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('\u2022', style: style),
              const SizedBox(width: 5),
              Expanded(
                child: child,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
