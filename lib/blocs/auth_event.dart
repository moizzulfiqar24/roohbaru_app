import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  EmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class EmailSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  EmailSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {}
