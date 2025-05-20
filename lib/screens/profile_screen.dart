import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../utils/mood_utils.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/avatar_animation.dart';
import '../widgets/profile/profile_info.dart';

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
    return Scaffold(
      backgroundColor: defaultMoodBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const ProfileHeader(),
                const SizedBox(height: 40),
                const SizedBox(height: 24),
                AvatarAnimation(onCompleted: _onAnimationComplete),
                const SizedBox(height: 24),
                if (_showInfo)
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        final user = state.user;
                        return ProfileInfo(
                          name: user.displayName ?? '',
                          email: user.email ?? '',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
