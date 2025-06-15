import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Fired at startup to kick off the 3s splash timer
class AppStarted extends AppEvent {
  const AppStarted();
}

/// Dispatched internally when the 3s timer completes
class SplashCompleted extends AppEvent {
  const SplashCompleted();
}
