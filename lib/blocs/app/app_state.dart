import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

/// Showing the intro/splash screen
class SplashInProgress extends AppState {
  const SplashInProgress();
}

/// After 3s, switch to the real app
class AppReady extends AppState {
  const AppReady();
}
