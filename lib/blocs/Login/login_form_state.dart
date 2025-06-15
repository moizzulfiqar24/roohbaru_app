import 'package:equatable/equatable.dart';

class LoginFormState extends Equatable {
  final String email;
  final bool emailValid;
  final String password;
  final bool obscurePassword;

  const LoginFormState({
    this.email = '',
    this.emailValid = false,
    this.password = '',
    this.obscurePassword = true,
  });

  LoginFormState copyWith({
    String? email,
    bool? emailValid,
    String? password,
    bool? obscurePassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      emailValid: emailValid ?? this.emailValid,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  List<Object?> get props => [email, emailValid, password, obscurePassword];
}
