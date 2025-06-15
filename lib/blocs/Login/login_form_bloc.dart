import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_form_event.dart';
import 'login_form_state.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc() : super(const LoginFormState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginTogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  void _onEmailChanged(LoginEmailChanged e, Emitter<LoginFormState> emit) {
    final valid = _emailRegex.hasMatch(e.email.trim());
    emit(state.copyWith(email: e.email, emailValid: valid));
  }

  void _onPasswordChanged(LoginPasswordChanged e, Emitter<LoginFormState> emit) {
    emit(state.copyWith(password: e.password));
  }

  void _onTogglePasswordVisibility(
      LoginTogglePasswordVisibility _, Emitter<LoginFormState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
}
