part of 'navbar_new_entry_bloc.dart';

abstract class NavbarNewEntryEvent extends Equatable {
  const NavbarNewEntryEvent();

  @override
  List<Object> get props => [];
}

class NavbarNewEntryPressedDown extends NavbarNewEntryEvent {
  const NavbarNewEntryPressedDown();
}

class NavbarNewEntryPressedUp extends NavbarNewEntryEvent {
  const NavbarNewEntryPressedUp();
}

class NavbarNewEntryPressedCancel extends NavbarNewEntryEvent {
  const NavbarNewEntryPressedCancel();
}
