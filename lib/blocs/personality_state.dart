import 'package:equatable/equatable.dart';

class PersonalityState extends Equatable {
  /// The set of currently selected personalities.
  final Set<String> selected;

  const PersonalityState({required this.selected});

  /// Initial state: only 'Supportive' is on by default.
  factory PersonalityState.initial() =>
      PersonalityState(selected: {'Supportive'});

  @override
  List<Object?> get props => [selected];

  PersonalityState copyWith({Set<String>? selected}) =>
      PersonalityState(selected: selected ?? this.selected);
}
