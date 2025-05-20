// lib/widgets/analytics_card.dart
import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final changeText = hasChange
        ? '${isIncrease ? '+' : '-'}${changePercent.toStringAsFixed(0)}%'
        : '-';
    final changeColor =
        !hasChange ? Colors.grey : (isIncrease ? Colors.green : Colors.red);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 4),
                Text('$total',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(changeText,
                style:
                    TextStyle(color: changeColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
