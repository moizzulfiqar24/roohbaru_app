import 'package:equatable/equatable.dart';
import '../models/journal_entry.dart';

class SearchState extends Equatable {
  final List<JournalEntry> allEntries;
  final List<JournalEntry> filteredEntries;
  final String query;
  final String? mood;
  final DateTime? date;
  final bool withPhotosOnly;

  const SearchState({
    required this.allEntries,
    required this.filteredEntries,
    required this.query,
    required this.mood,
    required this.date,
    required this.withPhotosOnly,
  });

  factory SearchState.initial() {
    return const SearchState(
      allEntries: [],
      filteredEntries: [],
      query: '',
      mood: null,
      date: null,
      withPhotosOnly: false,
    );
  }

  SearchState copyWith({
    List<JournalEntry>? allEntries,
    List<JournalEntry>? filteredEntries,
    String? query,
    String? mood,
    DateTime? date,
    bool? withPhotosOnly,
  }) {
    return SearchState(
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      query: query ?? this.query,
      mood: mood ?? this.mood,
      date: date ?? this.date,
      withPhotosOnly: withPhotosOnly ?? this.withPhotosOnly,
    );
  }

  @override
  List<Object?> get props => [
        allEntries,
        filteredEntries,
        query,
        mood,
        date,
        withPhotosOnly,
      ];
}
