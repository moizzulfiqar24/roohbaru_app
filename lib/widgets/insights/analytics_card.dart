import 'package:flutter/material.dart';

class AnalyticsCard extends StatefulWidget {
  final String title;
  final int total;
  final double changePercent;
  final bool hasChange;
  final bool isIncrease;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.total,
    required this.changePercent,
    required this.hasChange,
    required this.isIncrease,
  });

  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnalyticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.total != oldWidget.total ||
        widget.changePercent != oldWidget.changePercent) {
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
    final changeText = widget.hasChange
        ? '${widget.isIncrease ? '+' : '-'}${widget.changePercent.toStringAsFixed(0)}%'
        : '-';
    final changeColor = !widget.hasChange
        ? Colors.grey.shade400
        : (widget.isIncrease
            ? const Color(0xFF34C759)
            : const Color(0xFFFF3B30));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              // margin:
              //     const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20.0),
              //   color: Colors.white.withOpacity(0.9),
              //   gradient: LinearGradient(
              //     colors: [
              //       Colors.white.withOpacity(0.95),
              //       Colors.white.withOpacity(0.85),
              //     ],
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //   ),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.1),
              //       blurRadius: 15,
              //       spreadRadius: 3,
              //       offset: const Offset(0, 5),
              //     ),
              //     BoxShadow(
              //       color: Colors.white.withOpacity(0.5),
              //       blurRadius: 10,
              //       spreadRadius: 2,
              //       offset: const Offset(0, -2),
              //     ),
              //   ],
              //   border: Border.all(
              //     color: Colors.grey.withOpacity(0.1),
              //     width: 1,
              //   ),
              // ),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(24.0),
              //   color: Colors.white.withOpacity(0.9),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 20,
              //       spreadRadius: 5,
              //       offset: const Offset(0, 10),
              //     ),
              //   ],
              //   border: Border.all(
              //     color: Theme.of(context).brightness == Brightness.dark
              //         ? Colors.white.withOpacity(0.1)
              //         : Colors.grey.withOpacity(0.1),
              //     width: 1,
              //   ),
              // ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                // color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.total}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: changeColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      changeText,
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Text',
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
