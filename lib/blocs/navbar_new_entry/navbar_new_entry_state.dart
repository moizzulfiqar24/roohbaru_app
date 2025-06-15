part of 'navbar_new_entry_bloc.dart';

class NavbarNewEntryState extends Equatable {
  final double scale;
  const NavbarNewEntryState({this.scale = 1.0});

  NavbarNewEntryState copyWith({double? scale}) {
    return NavbarNewEntryState(
      scale: scale ?? this.scale,
    );
  }

  @override
  List<Object> get props => [scale];
}
