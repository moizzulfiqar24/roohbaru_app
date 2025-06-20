import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/screens/welcome_screen.dart';
import 'package:roohbaru_app/services/auth_service.dart';

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
    'WelcomeScreen golden',
    fileName: 'welcome_screen',
    builder: () => MaterialApp(
      home: Center(
        child: ConstrainedBox(
          // iPhone 16 Pro Max logical size
          constraints: BoxConstraints.tight(Size(430, 932)),
          child: BlocProvider<AuthBloc>(
            // Inject our dummy service so no Firebase calls occur
            create: (_) => AuthBloc(DummyAuthService()),
            child: const WelcomeScreen(),
          ),
        ),
      ),
    ),
  );
}
