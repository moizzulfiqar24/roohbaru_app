import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef CategoryTap = void Function(String category);

class MoodBarChart extends StatefulWidget {
  final Map<String, int> data;
  final String? selectedCategory;
  final CategoryTap onCategoryTap;

  const MoodBarChart({
    super.key,
    required this.data,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  State<MoodBarChart> createState() => _MoodBarChartState();
}

class _MoodBarChartState extends State<MoodBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize animations for each bar
    _barAnimations = widget.data.entries.toList().asMap().entries.map((_) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        ),
      );
    }).toList();

    // Start animation after a slight delay
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(MoodBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _controller.reset();
      _barAnimations = widget.data.entries.toList().asMap().entries.map((_) {
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );
      }).toList();
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
    final maxValue = widget.data.values.isEmpty
        ? 1
        : widget.data.values.reduce((a, b) => a > b ? a : b);
    final total = widget.data.values.fold<int>(0, (sum, v) => sum + v);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                widget.data.entries.toList().asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final value = entry.value;
              final heightRatio = total == 0 ? 0.0 : value / maxValue;
              final shareRatio = total == 0 ? 0.0 : value / total;
              final percentage = '${(shareRatio * 100).round()}%';
              final isSelected = entry.key == widget.selectedCategory;

              final baseColor = _getBarColor(entry.key);
              final color = isSelected ? baseColor : baseColor.withOpacity(0.9);
              final darkColor = _darken(baseColor, 0.15);

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onCategoryTap(entry.key),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height:
                            200 * (_barAnimations[index].value * heightRatio),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            colors: [color, darkColor],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(isSelected ? 0.4 : 0.2),
                              blurRadius: isSelected ? 12 : 8,
                              spreadRadius: isSelected ? 2 : 1,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: heightRatio > 0.2 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              percentage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _getBarColor(String category) {
    switch (category.toLowerCase()) {
      case 'positive':
        return const Color(0xFF34C759); // Apple-inspired green
      case 'neutral':
        return const Color(0xFFFFCC00); // Vibrant yellow
      case 'negative':
        return const Color(0xFFFF3B30); // Apple-inspired red
      default:
        return Colors.grey.shade400;
    }
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
