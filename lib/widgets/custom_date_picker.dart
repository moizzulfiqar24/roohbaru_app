import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  // Force lastDate to today if not provided
  DateTime? lastDate,
}) {
  final today = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate.isAfter(today) ? today : initialDate,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? today,
    builder: (ctx, child) {
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFFF2D96C), 
            onPrimary: Colors.black, 
            surface: Colors.white, 
            onSurface: Colors.black87, 
          ),
          dialogBackgroundColor: const Color(0xFFF8EED5), // overall bg
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4E4039),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
