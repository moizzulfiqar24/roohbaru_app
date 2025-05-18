import 'package:equatable/equatable.dart';
import '../models/journal_entry.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fired whenever JournalBloc emits a fresh list of entries.
class EntriesUpdated extends SearchEvent {
  final List<JournalEntry> entries;
  EntriesUpdated(this.entries);
  @override
  List<Object?> get props => [entries];
}

/// Fired as the user types into the search box.
class QueryChanged extends SearchEvent {
  final String query;
  QueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Fired when the user selects a mood filter (or clears it).
class MoodFilterChanged extends SearchEvent {
  final String? mood;
  MoodFilterChanged(this.mood);
  @override
  List<Object?> get props => [mood];
}

/// Fired when the user picks (or clears) a date.
class DateFilterChanged extends SearchEvent {
  final DateTime? date;
  DateFilterChanged(this.date);
  @override
  List<Object?> get props => [date];
}

/// Fired when the user toggles “Photos only”.
class PhotosFilterToggled extends SearchEvent {
  final bool withPhotosOnly;
  PhotosFilterToggled(this.withPhotosOnly);
  @override
  List<Object?> get props => [withPhotosOnly];
}
