import 'package:flutter/material.dart';

class navbarNewEntry extends StatelessWidget {
  const navbarNewEntry({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFB6F09C) : const Color(0xFFced4da),
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
        child: Icon(
          icon,
          size: 30,
          color: active ? Colors.black : Colors.black54,
        ),
      ),
    );
  }
}
