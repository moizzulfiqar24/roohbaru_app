import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_form_event.dart';
import 'signup_form_state.dart';

class SignupFormBloc extends Bloc<SignupFormEvent, SignupFormState> {
  SignupFormBloc() : super(const SignupFormState()) {
    on<EmailChanged>(_onEmailChanged);
    on<NameChanged>(_onNameChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ValidatePassword>(_onValidatePassword);
  }

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');

  void _onEmailChanged(EmailChanged e, Emitter<SignupFormState> emit) {
    final valid = _emailRegex.hasMatch(e.email.trim());
    emit(state.copyWith(email: e.email, isEmailValid: valid));
  }

  void _onNameChanged(NameChanged e, Emitter<SignupFormState> emit) {
    emit(state.copyWith(name: e.name));
  }

  void _onPasswordChanged(PasswordChanged e, Emitter<SignupFormState> emit) {
    emit(state.copyWith(password: e.password, showPasswordError: false));
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility _, Emitter<SignupFormState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onValidatePassword(ValidatePassword _, Emitter<SignupFormState> emit) {
    final valid = _passwordRegex.hasMatch(state.password.trim());
    if (!valid) {
      emit(state.copyWith(showPasswordError: true));
    }
  }
}
