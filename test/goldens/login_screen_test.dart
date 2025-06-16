// test/goldens/login_screen_test.dart

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roohbaru_app/services/auth_service.dart';
import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/blocs/Login/login_form_bloc.dart';
import 'package:roohbaru_app/screens/login_screen.dart';

/// A dummy AuthService so we never hit FirebaseAuth.instance in tests.
class DummyAuthService implements AuthService {
  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<User?> createUserWithEmailAndPassword(
          String email, String password) async =>
      null;

  @override
  Future<UserCredential?> loginWithGoogle() async => null;

  @override
  Future<User?> loginUserWithEmailAndPassword(
          String email, String password) async =>
      null;
}

void main() {
  goldenTest(
    'LoginScreen golden',
    fileName: 'login_screen',
    builder: () => MaterialApp(
      home: Center(
        child: ConstrainedBox(
          // iPhone 16 Pro Max logical size
          constraints: BoxConstraints.tight(const Size(430, 932)),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (_) => AuthBloc(DummyAuthService()),
              ),
              BlocProvider<LoginFormBloc>(
                create: (_) => LoginFormBloc(),
              ),
            ],
            child: const LoginScreen(),
          ),
        ),
      ),
    ),
  );
}
