import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

class TimeDisplay extends StatelessWidget {
  final int seconds;
  final double fontSize;
  final Color color;

  const TimeDisplay({
    super.key,
    required this.seconds,
    this.fontSize = 32,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      TimeFormatter.formatTime(seconds),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

