// test/goldens/signup_screen_test.dart

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roohbaru_app/screens/signup_screen.dart';
import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/blocs/Signup/signup_form_bloc.dart';
import 'package:roohbaru_app/services/auth_service.dart';

/// A no-op AuthService to avoid touching FirebaseAuth.instance
class DummyAuthService implements AuthService {
  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> loginWithGoogle() async => null;

  @override
  Future<User?> loginUserWithEmailAndPassword(
          String email, String password) async =>
      null;

  @override
  Future<User?> createUserWithEmailAndPassword(
          String email, String password) async =>
      null;

  @override
  Future<void> signOut() async {}
}

void main() {
  goldenTest(
    'SignupScreen golden',
    fileName: 'signup_screen',
    builder: () => MaterialApp(
      home: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(Size(430, 932)),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (_) => AuthBloc(DummyAuthService()),
              ),
              BlocProvider<SignupFormBloc>(
                create: (_) => SignupFormBloc(),
              ),
            ],
            child: const SignupScreen(),
          ),
        ),
      ),
    ),
  );
}
