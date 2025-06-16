import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_state.dart';
import '../blocs/Personality/personality_bloc.dart';
import '../utils/mood_utils.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/avatar_animation.dart';
import '../widgets/profile/profile_info.dart';
import '../widgets/profile/personality_selector.dart';
import '../blocs/Profile/profile_bloc.dart';
import '../blocs/Profile/profile_event.dart';
import '../blocs/Profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(create: (_) => ProfileBloc()),
        BlocProvider<PersonalityBloc>(create: (_) => PersonalityBloc()),
      ],
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

                    // AvatarAnimation now dispatches to ProfileBloc
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (ctx, profileState) {
                        return AvatarAnimation(
                          onCompleted: () => ctx
                              .read<ProfileBloc>()
                              .add(const AvatarAnimationCompleted()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Only show the info once the bloc’s `showInfo` is true
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (ctx, profileState) {
                        if (!profileState.showInfo) {
                          return const SizedBox.shrink();
                        }
                        return BlocBuilder<AuthBloc, AuthState>(
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
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 4),
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
                        );
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
