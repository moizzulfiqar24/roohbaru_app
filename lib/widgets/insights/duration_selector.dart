// lib/widgets/duration_selector.dart
import 'package:flutter/material.dart';
import '../../blocs/insights_event.dart';

class DurationSelector extends StatelessWidget {
  final DurationFilter current;
  final ValueChanged<DurationFilter> onChanged;

  const DurationSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  Widget _buildButton(
    String label,
    DurationFilter filter,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          'All-Time',
          DurationFilter.allTime,
          current == DurationFilter.allTime,
          () => onChanged(DurationFilter.allTime),
        ),
        const SizedBox(width: 8),
        _buildButton(
          '30d',
          DurationFilter.last30Days,
          current == DurationFilter.last30Days,
          () => onChanged(DurationFilter.last30Days),
        ),
        const SizedBox(width: 8),
        _buildButton(
          '7d',
          DurationFilter.last7Days,
          current == DurationFilter.last7Days,
          () => onChanged(DurationFilter.last7Days),
        ),
      ],
    );
  }
}
