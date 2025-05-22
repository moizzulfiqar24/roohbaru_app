import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roohbaru_app/screens/login_screen.dart';
import 'package:roohbaru_app/screens/signup_screen.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_event.dart';
import '../blocs/Auth/auth_state.dart';
import 'home_screen.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
    //   ..initialize().then((_) {
    //     _controller.setLooping(false);
    //     _controller.setVolume(0);
    //     // _controller.play();
    //     if (mounted) setState(() {});
    //   });
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)),
              (_) => false,
            );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/intro.png',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(flex: 4),

                    // Sign Up
                    PrimaryButton(
                      label: 'Sign Up',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sign In
                    SecondaryButton(
                      label: 'Sign In',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 28),
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
