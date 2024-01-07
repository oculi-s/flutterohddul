import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Widget? child;
  final DateTime to;
  TimerWidget({
    this.child,
    required this.to,
  });
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer = Timer(Duration(days: 1), () {});
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _calculateRemainingTime();
    });
  }

  void _calculateRemainingTime() {
    DateTime now = DateTime.now();
    Duration difference = widget.to.difference(now);
    _remainingTime = difference.isNegative ? Duration.zero : difference;
    if (_remainingTime == Duration.zero) {
      _timer.cancel();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.child ?? Container(),
        Text(
          '${_remainingTime.inHours}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
