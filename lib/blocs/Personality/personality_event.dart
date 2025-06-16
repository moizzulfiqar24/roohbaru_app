import 'package:equatable/equatable.dart';

abstract class PersonalityEvent extends Equatable {
  const PersonalityEvent();
  @override
  List<Object?> get props => [];
}

class TogglePersonality extends PersonalityEvent {
  final String personality;
  const TogglePersonality(this.personality);
  @override
  List<Object?> get props => [personality];
}
