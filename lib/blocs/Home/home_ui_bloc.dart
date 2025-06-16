import 'package:bloc/bloc.dart';
import 'home_ui_event.dart';
import 'home_ui_state.dart';

class HomeUiBloc extends Bloc<HomeUiEvent, HomeUiState> {
  HomeUiBloc() : super(const HomeUiState()) {
    on<SelectTab>((event, emit) {
      emit(state.copyWith(selectedIndex: event.index));
    });

    on<PickDate>((event, emit) {
      emit(state.copyWith(
        selectedDate: event.date,
        updateDate: true,
      ));
    });

    on<ResetDate>((event, emit) {
      emit(state.copyWith(
        selectedDate: null,
        updateDate: true,
      ));
    });
  }
}
