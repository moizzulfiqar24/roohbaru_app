import 'package:equatable/equatable.dart';

abstract class PersonalityEvent extends Equatable {
  const PersonalityEvent();
  @override
  List<Object?> get props => [];
}

/// Toggle a single personality on/off.
class TogglePersonality extends PersonalityEvent {
  final String personality;
  const TogglePersonality(this.personality);
  @override
  List<Object?> get props => [personality];
}
