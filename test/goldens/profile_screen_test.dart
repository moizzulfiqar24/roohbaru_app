import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/blocs/Auth/auth_event.dart';
import 'package:roohbaru_app/blocs/Auth/auth_state.dart';
import 'package:roohbaru_app/blocs/Profile/profile_bloc.dart';
import 'package:roohbaru_app/blocs/Profile/profile_event.dart';
import 'package:roohbaru_app/blocs/Profile/profile_state.dart';
import 'package:roohbaru_app/blocs/Personality/personality_bloc.dart';
import 'package:roohbaru_app/screens/profile_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

class _FakeAuthState extends Fake implements AuthState {}

class _FakeProfileEvent extends Fake implements ProfileEvent {}

class _FakeProfileState extends Fake implements ProfileState {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthEvent());
    registerFallbackValue(_FakeAuthState());
    registerFallbackValue(_FakeProfileEvent());
    registerFallbackValue(_FakeProfileState());
  });

  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late User fakeUser;

  setUp(() {
    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    fakeUser = MockUser();

    // Stub a user name + email
    when(() => fakeUser.uid).thenReturn('u1');
    when(() => fakeUser.displayName).thenReturn('Moiz Spammable');
    when(() => fakeUser.email).thenReturn('moizspammable@gmail.com');

    // AuthBloc: immediately authenticated
    final authState = AuthAuthenticated(fakeUser);
    whenListen(
      authBloc,
      Stream.value(authState),
      initialState: authState,
    );
    when(() => authBloc.state).thenReturn(authState);

    // ProfileBloc: pretend the avatar animation has completed, so showInfo=true
    final profState = const ProfileState(showInfo: true);
    whenListen(
      profileBloc,
      Stream.value(profState),
      initialState: profState,
    );
    when(() => profileBloc.state).thenReturn(profState);
  });

  tearDown(() {
    authBloc.close();
    profileBloc.close();
  });

  group('ProfileScreen golden', () {
    goldenTest(
      'full profile – name, email, personality grid',
      fileName: 'profile_screen',
      builder: () => GoldenTestGroup(
        scenarioConstraints: BoxConstraints.tight(Size(430, 932)),
        children: [
          GoldenTestScenario(
            name: 'initial',
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<ProfileBloc>.value(value: profileBloc),
                // Use your real PersonalityBloc so that "Supportive" is selected by default
                BlocProvider(create: (_) => PersonalityBloc()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
                home: const ProfileScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
