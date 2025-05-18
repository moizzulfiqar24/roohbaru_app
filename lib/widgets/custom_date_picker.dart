// lib/widgets/custom_date_picker.dart

import 'package:flutter/material.dart';

/// Shows a calendar dialog styled exactly like your mockup,
/// but only allowing selection up to today (no future dates).
/// Usage:
/// ```dart
/// final picked = await showCustomDatePicker(
///   context: context,
///   initialDate: DateTime.now(),
/// );
/// ```
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
            primary: const Color(0xFFF2D96C), // header bg & selected day
            onPrimary: Colors.black, // header text & selected text
            surface: Colors.white, // calendar surface
            onSurface: Colors.black87, // dates & weekdays
          ),
          dialogBackgroundColor: const Color(0xFFF8EED5), // overall bg
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4E4039), // OK/Cancel
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
