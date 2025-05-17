// lib/widgets/header_row.dart

import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  final VoidCallback onCalendarPressed;
  final VoidCallback onLogoutPressed;

  const HeaderRow({
    Key? key,
    required this.onCalendarPressed,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.calendar_month_rounded,
            size: 30,
            color: Colors.black,
          ),
          onPressed: onCalendarPressed,
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
