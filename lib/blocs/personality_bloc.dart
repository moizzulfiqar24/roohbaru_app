import 'package:bloc/bloc.dart';
import 'personality_event.dart';
import 'personality_state.dart';

/// All available AI personalities.
class PersonalityBloc extends Bloc<PersonalityEvent, PersonalityState> {
  static const List<String> allPersonalities = [
    'Supportive',
    'Calm',
    'Cheerful',
    'Empathetic',
    'Gentle',
    'Humorous',
    'Mindful',
    'Optimistic',
  ];

  PersonalityBloc() : super(PersonalityState.initial()) {
    on<TogglePersonality>(_onToggle);
  }

  void _onToggle(TogglePersonality event, Emitter<PersonalityState> emit) {
    final current = state.selected;
    final updated = Set<String>.from(current);

    if (current.contains(event.personality)) {
      // Only remove if more than one remains
      if (updated.length > 1) updated.remove(event.personality);
    } else {
      updated.add(event.personality);
    }

    emit(state.copyWith(selected: updated));
  }
}
