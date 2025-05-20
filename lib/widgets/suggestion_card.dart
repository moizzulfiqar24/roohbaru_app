import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.icon,
    required this.suggestion,
    required this.context,
  });

  final IconData icon;
  final String suggestion;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: suggestion.isNotEmpty ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        // decoration: BoxDecoration(
        //   color: const Color(0xFF2E2E2E).withOpacity(0.1),
        //   // color: Colors.white.withOpacity(0.4),
        //   borderRadius: BorderRadius.circular(10),
        //   // border: Border.all(
        //   //   color: Colors.black.withOpacity(0.1),
        //   //   width: 1,
        //   // ),
        // ),
        decoration: BoxDecoration(
          // color: Colors.white.withOpacity(0.3),
          color: const Color(0xFF2E2E2E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                      fontFamily: 'lufga-regular',
                      fontSize: 14,
                      // color: Color(0xFF4A4A4A),
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
