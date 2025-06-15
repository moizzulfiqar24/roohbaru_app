// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8eed5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // bg2.png on top of backgroundColor
          Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Title + subtitle
                  const Text(
                    'Welcome.',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                      fontFamily: 'lufga-bold',
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'select your preferred method to create an account here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'lufga-regular'),
                  ),

                  const Spacer(flex: 2),

                  // // Apple Sign-up
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: ElevatedButton.icon(
                  //     icon: const Icon(
                  //       PhosphorIcons.appleLogo,
                  //       size: 24,
                  //       color: Colors.white,
                  //     ),
                  //     label: const Text('Sign up with apple'),
                  //     onPressed: () {
                  //       // TODO: hook up Apple sign-in
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (_) => const SignupScreen()),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.black,
                  //       foregroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  // Google Sign-up
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Sign up with Google',
                        style: TextStyle(fontFamily: "lufga-regular"),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email & Password Sign-up
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.mail_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                      label: const Text(
                        'Email and Password',
                        style: TextStyle(fontFamily: "lufga-regular"),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECCDAA),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Already-a-user link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a user? ',
                        style: TextStyle(fontFamily: "lufga-regular"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            // decoration: TextDecoration.underline,
                            fontFamily: "lufga-regular",
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // Terms & Privacy
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        children: [
                          const TextSpan(
                              text:
                                  'by signing up to this app you agree with our '),
                          TextSpan(
                            text: 'terms of use',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            // TODO: wrap with GestureRecognizer to open link
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'privacy policy',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            // TODO: wrap with GestureRecognizer to open link
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
