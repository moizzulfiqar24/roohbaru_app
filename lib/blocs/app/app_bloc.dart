import 'dart:async';
import 'package:bloc/bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const SplashInProgress()) {
    on<AppStarted>(_onAppStarted);
    on<SplashCompleted>((event, emit) => emit(const AppReady()));
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    // Begin with the splash
    emit(const SplashInProgress());
    // Wait exactly 3 seconds, then fire SplashCompleted
    await Future.delayed(const Duration(seconds: 3));
    add(const SplashCompleted());
  }
}
