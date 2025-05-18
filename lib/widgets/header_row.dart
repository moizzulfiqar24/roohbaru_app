// // lib/widgets/header_row.dart

// import 'package:flutter/material.dart';

// class HeaderRow extends StatelessWidget {
//   final VoidCallback onCalendarPressed;
//   final VoidCallback onLogoutPressed;

//   const HeaderRow({
//     Key? key,
//     required this.onCalendarPressed,
//     required this.onLogoutPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(
//             Icons.calendar_month_rounded,
//             size: 30,
//             color: Colors.black,
//           ),
//           onPressed: onCalendarPressed,
//         ),
//         const Spacer(),
//         IconButton(
//           icon: const Icon(
//             Icons.logout,
//             size: 25,
//             color: Colors.black,
//           ),
//           onPressed: onLogoutPressed,
//         ),
//       ],
//     );
//   }
// }

// lib/widgets/header_row.dart

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
        // Either calendar icon or Reset pill
        if (!isDateSelected) ...[
          IconButton(
            icon: const Icon(
              Icons.calendar_month_rounded,
              size: 30,
              color: Colors.black,
            ),
            onPressed: onCalendarPressed,
          ),
        ] else ...[
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
        ],
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
