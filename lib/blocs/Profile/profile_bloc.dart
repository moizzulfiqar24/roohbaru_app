import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roohbaru_app/blocs/Profile/profile_state.dart';
import 'profile_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState.initial()) {
    on<AvatarAnimationCompleted>((event, emit) {
      emit(state.copyWith(showInfo: true));
    });
  }
}
