import 'package:equatable/equatable.dart';

abstract class SignupFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailChanged extends SignupFormEvent {
  final String email;
  EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class NameChanged extends SignupFormEvent {
  final String name;
  NameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class PasswordChanged extends SignupFormEvent {
  final String password;
  PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class TogglePasswordVisibility extends SignupFormEvent {}

class ValidatePassword extends SignupFormEvent {}
