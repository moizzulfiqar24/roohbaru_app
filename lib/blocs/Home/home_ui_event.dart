/// Base class for all Home UI events
abstract class HomeUiEvent {
  const HomeUiEvent();
}

/// Fired when the bottom‐nav tab changes.
class SelectTab extends HomeUiEvent {
  final int index;
  const SelectTab(this.index);
}

/// Fired when the user picks a date from the calendar.
class PickDate extends HomeUiEvent {
  final DateTime date;
  const PickDate(this.date);
}

/// Fired when the user taps "Reset".
class ResetDate extends HomeUiEvent {
  const ResetDate();
}
