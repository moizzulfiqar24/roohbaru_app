import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  /// Called when the calendar icon is tapped (only when [isDateSelected] is false).
  final VoidCallback onCalendarPressed;

  /// Called when the logout icon is tapped.
  final VoidCallback onLogoutPressed;

  /// If true, show the Reset pill instead of the calendar icon.
  final bool isDateSelected;

  /// Called when the Reset pill is tapped (only when [isDateSelected] is true).
  final VoidCallback? onReset;

  const HeaderRow({
    Key? key,
    required this.onCalendarPressed,
    required this.onLogoutPressed,
    this.isDateSelected = false,
    this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Animated switch between calendar icon and Reset pill
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isDateSelected
              ? GestureDetector(
                  key: const ValueKey('reset'),
                  onTap: onReset,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  key: const ValueKey('calendar'),
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: onCalendarPressed,
                ),
        ),

        const Spacer(),

        IconButton(
          icon: const Icon(
            Icons.logout,
            size: 25,
            color: Colors.black,
          ),
          onPressed: onLogoutPressed,
        ),
      ],
    );
  }
}
