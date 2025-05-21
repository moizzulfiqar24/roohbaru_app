import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/personality_bloc.dart';
import '../utils/mood_utils.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/avatar_animation.dart';
import '../widgets/profile/profile_info.dart';
import '../widgets/profile/personality_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showInfo = false;

  void _onAnimationComplete() {
    setState(() {
      _showInfo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalityBloc(),
      child: Scaffold(
        backgroundColor: defaultMoodBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ProfileHeader(),
                    const SizedBox(height: 40),
                    AvatarAnimation(onCompleted: _onAnimationComplete),
                    const SizedBox(height: 16),
                    if (_showInfo)
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthAuthenticated) {
                            final user = state.user;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ProfileInfo(
                                  name: user.displayName ?? '',
                                  email: user.email ?? '',
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 1,
                                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.9),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                Center(child: const PersonalitySelector()),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    const SizedBox(height: 40),
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
