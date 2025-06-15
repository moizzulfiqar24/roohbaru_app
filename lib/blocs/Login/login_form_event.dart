import 'package:equatable/equatable.dart';

abstract class LoginFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginFormEvent {
  final String email;
  LoginEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginFormEvent {
  final String password;
  LoginPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class LoginTogglePasswordVisibility extends LoginFormEvent {}
