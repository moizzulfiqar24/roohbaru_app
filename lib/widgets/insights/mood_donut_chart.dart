import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MoodDonutChart extends StatefulWidget {
  final Map<String, int> data;

  const MoodDonutChart({super.key, required this.data});

  @override
  State<MoodDonutChart> createState() => _MoodDonutChartState();
}

class _MoodDonutChartState extends State<MoodDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(MoodDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(24.0),
      //   color: Colors.white.withOpacity(0.9),
      //   // boxShadow: [
      //   //   BoxShadow(
      //   //     color: Colors.black.withOpacity(0.08),
      //   //     blurRadius: 12,
      //   //     spreadRadius: 2,
      //   //     offset: const Offset(0, 4),
      //   //   ),
      //   // ],
      //   // border: Border.all(
      //   //   color: Colors.grey.withOpacity(0.1),
      //   //   width: 1,
      //   // ),
      // ),
      // decoration: BoxDecoration(
      //     // borderRadius: BorderRadius.circular(24.0),
      //     // color: Colors.white.withOpacity(1.0),
      //     // boxShadow: [
      //     //   BoxShadow(
      //     //     color: Colors.black.withOpacity(0.05),
      //     //     blurRadius: 20,
      //     //     spreadRadius: 5,
      //     //     offset: const Offset(0, 10),
      //     //   ),
      //     // ],
      //     // border: Border.all(
      //     //   color: Theme.of(context).brightness == Brightness.dark
      //     //       ? Colors.white.withOpacity(0.1)
      //     //       : Colors.grey.withOpacity(0.1),
      //     //   width: 1,
      //     // ),
      //     ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _MoodDonutPainter(widget.data, _animation.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _MoodDonutPainter extends CustomPainter {
  final Map<String, int> data;
  final double animationValue;

  _MoodDonutPainter(this.data, this.animationValue);

  static const _moodColors = {
    'Happy': Color(0xFF34C759), // Apple green
    'Excited': Color(0xFFFF9500), // Vibrant orange
    'Calm': Color(0xFF5856D6), // Soft purple
    'Grateful': Color(0xFF4CD964), // Light green
    'Loving': Color(0xFFFF2D55), // Warm pink
    'Confident': Color(0xFF007AFF), // Apple blue
    'Inspired': Color(0xFF5AC8FA), // Light blue
    'Surprised': Color(0xFFFFCC00), // Bright yellow
    'Bored': Color(0xFF8E8E93), // Neutral grey
    'Distracted': Color(0xFFB0B0B0), // Light grey
    'Sad': Color(0xFFFF3B30), // Apple red
    'Angry': Color(0xFFCC3300), // Deep red
    'Anxious': Color(0xFFF7CA18), // Amber
    'Lonely': Color(0xFF5856D6), // Dark purple
    'Guilty': Color(0xFF8B5E3C), // Brown
    'Jealous': Color(0xFF009688), // Teal
    'Confused': Color(0xFF7C4DFF), // Indigo
    'Restless': Color(0xFFAF52DE), // Light purple
  };

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        min(size.width, size.height) / 2 * 0.65; // Adjusted for thicker lines
    const donutThickness = 40.0; // Increased from 20.0 to 30.0 for wider lines
    var startAngle = -pi / 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final entries = data.entries.toList();
    const gapAngle = 0.02 * pi;

    // Draw background donut ring
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = donutThickness
      ..color = Colors.grey.withOpacity(0.1);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw each segment
    for (var i = 0; i < entries.length; i++) {
      final mood = entries[i].key;
      final count = entries[i].value;
      final share = count / total;
      final sweep =
          (2 * pi - gapAngle * entries.length) * share * animationValue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = donutThickness
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            _moodColors[mood] ?? Colors.grey,
            _darken(_moodColors[mood] ?? Colors.grey, 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      // Draw label
      final midAngle = startAngle + sweep / 2;
      final labelRadius =
          radius + donutThickness + 14; // Adjusted for thicker lines
      final labelX = center.dx + cos(midAngle) * labelRadius;
      final labelY = center.dy + sin(midAngle) * labelRadius;
      final percent = (share * 100).round();

      textPainter.text = TextSpan(
        text: '$mood\n$percent%',
        style: TextStyle(
          color: Colors.black.withOpacity(0.8),
          fontSize: 12,
          // fontWeight: FontWeight.w500,
          fontWeight: FontWeight.bold,
          // fontFamily: 'SF Pro Text',
          letterSpacing: 0.2,
        ),
      );
      textPainter.layout();

      final labelOffset = Offset(
        labelX - textPainter.width / 2,
        labelY - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);

      startAngle += sweep + gapAngle;
    }

    // Subtle inner shadow for depth
    final innerShadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.02);
    canvas.drawCircle(center, radius - donutThickness / 2, innerShadowPaint);
  }

  @override
  bool shouldRepaint(covariant _MoodDonutPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue;
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
