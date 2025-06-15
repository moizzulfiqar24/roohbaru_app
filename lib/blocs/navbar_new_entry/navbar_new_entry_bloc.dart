import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navbar_new_entry_event.dart';
part 'navbar_new_entry_state.dart';

class NavbarNewEntryBloc
    extends Bloc<NavbarNewEntryEvent, NavbarNewEntryState> {
  NavbarNewEntryBloc() : super(const NavbarNewEntryState()) {
    on<NavbarNewEntryPressedDown>((event, emit) {
      emit(state.copyWith(scale: 0.9));
    });
    on<NavbarNewEntryPressedUp>((event, emit) {
      emit(state.copyWith(scale: 1.0));
    });
    on<NavbarNewEntryPressedCancel>((event, emit) {
      emit(state.copyWith(scale: 1.0));
    });
  }
}
