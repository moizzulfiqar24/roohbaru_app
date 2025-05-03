import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      log('Google sign-in initiated');
      final userCred = await _authService.loginWithGoogle();
      if (userCred?.user != null) {
        log("User signed in: ${userCred!.user!.uid}");
        emit(AuthAuthenticated(userCred.user!));
      } else {
        emit(AuthError("Google sign-in was cancelled"));
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      log("Google sign-in failed: $e\n$st");
      emit(AuthError("Google sign-in failed. Please try again."));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      log("Sign-out failed: $e");
      emit(AuthError("Sign-out failed. Please try again."));
    }
  }
}
