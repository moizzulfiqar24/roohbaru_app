import 'package:equatable/equatable.dart';
import '../../models/journal_entry.dart';

/// Which time window is selected.
enum DurationFilter { allTime, last30Days, last7Days }

abstract class InsightsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// When JournalBloc emits new entries.
class EntriesUpdated extends InsightsEvent {
  final List<JournalEntry> entries;
  EntriesUpdated(this.entries);
  @override
  List<Object?> get props => [entries];
}

/// User tapped one of the duration buttons.
class DurationChanged extends InsightsEvent {
  final DurationFilter filter;
  DurationChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

/// User tapped one of the bars (Positive/Neutral/Negative).
class CategorySelected extends InsightsEvent {
  final String category;
  CategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}
