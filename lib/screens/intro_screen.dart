import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roohbaru_app/screens/login_screen.dart';
import 'package:roohbaru_app/screens/signup_screen.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..initialize().then((_) {
        // _controller.setLooping(true);
        _controller.setLooping(false); 
        _controller.setVolume(0);
        // _controller.play();
        // setState(() {});
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  Widget _buildGoogleButton() {
    return ElevatedButton.icon(
      icon: Image.asset('assets/images/google.png', height: 20, width: 20),
      label: const Text('Continue with Google',
          style: TextStyle(fontWeight: FontWeight.w600)),
      onPressed: _handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmailButton() {
    return ElevatedButton(
      child: const Text('Log In with Email',
          style: TextStyle(fontWeight: FontWeight.w600)),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignupText() {
    return TextButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SignupScreen()));
      },
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 16,
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: const [
        Text(
          'Roohbaru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'JOURNAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
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
            if (_controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Container(color: Colors.black),
            Container(color: Colors.black.withOpacity(0.4)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Image.asset('assets/images/logo.png',
                        height: 72, width: 72),
                    const SizedBox(height: 16),
                    _buildAppTitle(),
                    const Spacer(flex: 3),
                    _buildGoogleButton(),
                    const SizedBox(height: 16),
                    _buildEmailButton(),
                    const SizedBox(height: 20),
                    _buildSignupText(),
                    const Spacer(),
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
