// lib/widgets/insights/mood_bar_chart.dart

import 'package:flutter/material.dart';

typedef CategoryTap = void Function(String category);

class MoodBarChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 1) Compute both max and total
    final maxValue =
        data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);

    final total = data.values.fold<int>(0, (sum, v) => sum + v);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((entry) {
          final value = entry.value;

          // 2) Height ratio: you can choose max-value scaling...
          // final heightRatio = maxValue == 0 ? 0.0 : value / maxValue;

          // ...or total-share scaling. Here we use total-share so bars reflect % of all entries:
          final heightRatio = total == 0 ? 0.0 : value / total;

          // 3) Share ratio for label
          final shareRatio = total == 0 ? 0.0 : value / total;
          final percentage = '${(shareRatio * 100).round()}%';

          // pick your colors
          final isSelected = entry.key == selectedCategory;
          final base = _getBarColor(entry.key);
          final color = isSelected ? base : base.withOpacity(0.85);
          final dark = _darken(color, 0.2);

          return GestureDetector(
            onTap: () => onCategoryTap(entry.key),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Outer container for fixed height
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 180,
                  width: 60,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // 4) Use heightRatio * maxInnerHeight
                    height: 160 * heightRatio,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [color, dark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              )
                            ]
                          : [
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      percentage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBarColor(String category) {
    switch (category.toLowerCase()) {
      case 'positive':
        return const Color(0xFF00D26A);
      case 'neutral':
        return const Color(0xFFFAA937);
      case 'negative':
        return const Color(0xFFE84855);
      default:
        return Colors.grey;
    }
  }

  Color _darken(Color color, double amt) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }
}
