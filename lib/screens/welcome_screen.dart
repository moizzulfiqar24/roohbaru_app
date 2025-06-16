import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_event.dart';
import '../blocs/Auth/auth_state.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8eed5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // bg2.png on top of the solid background
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

                  // Title
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

                  // Subtitle
                  const Text(
                    'select your preferred method to create an account here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'lufga-regular',
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Google Sign-Up Button
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (ctx, state) {
                      if (state is AuthAuthenticated) {
                        Navigator.of(ctx).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => HomeScreen(user: state.user)),
                          (_) => false,
                        );
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    builder: (ctx, state) {
                      if (state is AuthLoading) {
                        return const SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return SizedBox(
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
                            style: TextStyle(fontFamily: 'lufga-regular'),
                          ),
                          onPressed: () {
                            ctx.read<AuthBloc>().add(GoogleSignInRequested());
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
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email & Password Sign-Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.mail_rounded,
                        size: 22,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Email and Password',
                        style: TextStyle(fontFamily: 'lufga-regular'),
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

                  // Already-a-user? Log in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a user? ',
                        style: TextStyle(fontFamily: 'lufga-regular'),
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
                            // decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'lufga-regular',
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
                                'by signing up to this app you agree with our ',
                          ),
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
