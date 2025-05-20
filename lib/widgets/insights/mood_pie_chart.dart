// lib/widgets/insights/mood_pie_chart.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/mood_utils.dart'; // for moodBackgroundColors

class MoodPieChart extends StatelessWidget {
  final Map<String, int> data;

  const MoodPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MoodPieChartPainter(data),
      child: const SizedBox.expand(),
    );
  }
}

class _MoodPieChartPainter extends CustomPainter {
  final Map<String, int> data;
  _MoodPieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.9;
    var startAngle = -pi / 2; // start at top

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    data.forEach((mood, count) {
      final sweep = 2 * pi * (count / total);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = moodBackgroundColors[mood] ?? Colors.grey;

      // draw slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      // midpoint angle for label
      final midAngle = startAngle + sweep / 2;
      final labelRadius = radius * 0.65;
      final labelX = center.dx + cos(midAngle) * labelRadius;
      final labelY = center.dy + sin(midAngle) * labelRadius;

      // prepare label text: “Mood (xx%)”
      final percent = (count / total * 100).round();
      textPainter.text = TextSpan(
        text: '$mood\n$percent%',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // paint label centered
      final labelOffset = Offset(
        labelX - textPainter.width / 2,
        labelY - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);

      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant _MoodPieChartPainter old) {
    return old.data != data;
  }
}
