import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roohbaru_app/screens/intro_screen.dart';

void main() {
  goldenTest(
    'IntroScreen golden',
    fileName: 'intro_screen',
    builder: () => MaterialApp(
      home: Center(
        // Constrain to your device’s screen size:
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(Size(430, 932)),
          child: const IntroScreen(),
        ),
      ),
    ),
  );
}
