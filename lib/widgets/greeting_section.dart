// lib/widgets/greeting_section.dart

import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  final String greeting;

  const GreetingSection({Key? key, required this.greeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontFamily: 'lufga-bold',
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'reflect, grow, thrive',
            style: TextStyle(
              fontFamily: 'lufga-regular',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
