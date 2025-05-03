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
    on<EmailSignInRequested>(_onEmailSignIn);
    on<EmailSignUpRequested>(_onEmailSignUp);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = _authService.currentUser;
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
      final cred = await _authService.loginWithGoogle();
      if (cred?.user != null) {
        emit(AuthAuthenticated(cred!.user!));
      } else {
        emit(AuthError('Google sign-in cancelled'));
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      log('Google sign-in error: $e\n$st');
      emit(AuthError('Google sign-in failed'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onEmailSignIn(
      EmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginUserWithEmailAndPassword(
          event.email.trim(), event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Invalid email or password'));
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      log('Email sign-in error: $e\n$st');
      emit(AuthError('Email sign-in failed'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onEmailSignUp(
      EmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.createUserWithEmailAndPassword(
          event.email.trim(), event.password);
      if (user != null) {
        await user.updateDisplayName(event.name.trim());
        await user.reload();
        emit(AuthAuthenticated(_authService.currentUser!));
      } else {
        emit(AuthError('Sign-up failed'));
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      log('Email sign-up error: $e\n$st');
      emit(AuthError('Sign-up failed'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e, st) {
      log('Sign-out error: $e\n$st');
      emit(AuthError('Sign-out failed'));
      emit(AuthUnauthenticated());
    }
  }
}
