import 'package:flutter/material.dart';
import '../../blocs/Insights/insights_event.dart';

class DurationSelector extends StatefulWidget {
  final DurationFilter current;
  final ValueChanged<DurationFilter> onChanged;

  const DurationSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
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
  void didUpdateWidget(DurationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current != oldWidget.current) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildButton(
    String label,
    DurationFilter filter,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF007AFF).withOpacity(0.2)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF007AFF).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF007AFF)
                  : Colors.black.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(16.0),
            //   color: Colors.white.withOpacity(0.95),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withOpacity(0.08),
            //       blurRadius: 12,
            //       spreadRadius: 2,
            //       offset: const Offset(0, 4),
            //     ),
            //   ],
            //   border: Border.all(
            //     color: Colors.grey.withOpacity(0.1),
            //     width: 1,
            //   ),
            // ),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(16.0),
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
              borderRadius: BorderRadius.circular(16.0),
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
              children: [
                _buildButton(
                  'All-Time',
                  DurationFilter.allTime,
                  widget.current == DurationFilter.allTime,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  '30d',
                  DurationFilter.last30Days,
                  widget.current == DurationFilter.last30Days,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  '7d',
                  DurationFilter.last7Days,
                  widget.current == DurationFilter.last7Days,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
