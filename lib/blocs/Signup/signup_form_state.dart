import 'package:equatable/equatable.dart';

class SignupFormState extends Equatable {
  final String email;
  final bool isEmailValid;
  final String name;
  final String password;
  final bool obscurePassword;
  final bool showPasswordError;

  const SignupFormState({
    this.email = '',
    this.isEmailValid = false,
    this.name = '',
    this.password = '',
    this.obscurePassword = true,
    this.showPasswordError = false,
  });

  SignupFormState copyWith({
    String? email,
    bool? isEmailValid,
    String? name,
    String? password,
    bool? obscurePassword,
    bool? showPasswordError,
  }) {
    return SignupFormState(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      name: name ?? this.name,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      showPasswordError: showPasswordError ?? this.showPasswordError,
    );
  }

  @override
  List<Object?> get props => [
        email,
        isEmailValid,
        name,
        password,
        obscurePassword,
        showPasswordError,
      ];
}
