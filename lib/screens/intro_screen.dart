// // lib/screens/intro_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:roohbaru_app/screens/welcome_screen.dart';

// class IntroScreen extends StatefulWidget {
//   const IntroScreen({Key? key}) : super(key: key);

//   @override
//   State<IntroScreen> createState() => _IntroScreenState();
// }

// class _IntroScreenState extends State<IntroScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // after 3 seconds go to WelcomeScreen
//     Timer(const Duration(seconds: 3), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const WelcomeScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Image.asset(
//         'assets/images/intro_page_bg.png',
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       ),
//     );
//   }
// }


// lib/screens/intro_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roohbaru_app/screens/welcome_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // after 3 seconds, navigate to WelcomeScreen if still mounted
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    // cancel the timer if the widget is disposed before it fires
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/intro_page_bg.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
