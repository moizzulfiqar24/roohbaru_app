import 'package:flutter/material.dart';

class navbarNewEntry extends StatefulWidget {
  const navbarNewEntry({
    super.key,
    this.icon,
    this.iconWidget,
    required this.active,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final bool active;
  final VoidCallback onTap;

  @override
  State<navbarNewEntry> createState() => _navbarNewEntryState();
}

class _navbarNewEntryState extends State<navbarNewEntry>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0xFFB6F09C)
                : const Color(0xFFced4da),
            // color: active ? const Color(0xFFB6F09C) : const Color(0xFFb1b1b1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: widget.iconWidget ??
                Icon(
                  widget.icon,
                  size: 30,
                  color: widget.active ? Colors.black : Colors.black54,
                ),
          ),
        ),
      ),
    );
  }
}
