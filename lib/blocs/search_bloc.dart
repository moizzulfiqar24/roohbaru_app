import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/journal_entry.dart';
import 'journal_bloc.dart';
import 'journal_state.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final JournalBloc journalBloc;
  late final StreamSubscription journalSubscription;

  SearchBloc({required this.journalBloc}) : super(SearchState.initial()) {
    // 1. Register all handlers first
    on<EntriesUpdated>(_onEntriesUpdated);
    on<QueryChanged>(_onQueryChanged);
    on<MoodFilterChanged>(_onMoodFilterChanged);
    on<DateFilterChanged>(_onDateFilterChanged);
    on<PhotosFilterToggled>(_onPhotosFilterToggled);

    // 2. Seed initial entries if already loaded
    if (journalBloc.state is JournalLoaded) {
      final entries = (journalBloc.state as JournalLoaded).entries;
      add(EntriesUpdated(entries));
    }

    // 3. Subscribe to JournalBloc for future updates
    journalSubscription = journalBloc.stream.listen((js) {
      if (js is JournalLoaded) {
        add(EntriesUpdated(js.entries));
      }
    });
  }

  void _onEntriesUpdated(EntriesUpdated event, Emitter<SearchState> emit) {
    final filtered = _applyFilters(
      event.entries,
      state.query,
      state.mood,
      state.date,
      state.withPhotosOnly,
    );
    emit(state.copyWith(
      allEntries: event.entries,
      filteredEntries: filtered,
    ));
  }

  void _onQueryChanged(QueryChanged event, Emitter<SearchState> emit) {
    final filtered = _applyFilters(
      state.allEntries,
      event.query,
      state.mood,
      state.date,
      state.withPhotosOnly,
    );
    emit(state.copyWith(
      query: event.query,
      filteredEntries: filtered,
    ));
  }

  void _onMoodFilterChanged(
      MoodFilterChanged event, Emitter<SearchState> emit) {
    final filtered = _applyFilters(
      state.allEntries,
      state.query,
      event.mood,
      state.date,
      state.withPhotosOnly,
    );
    // Use full constructor so `mood: null` actually clears it
    emit(SearchState(
      allEntries: state.allEntries,
      filteredEntries: filtered,
      query: state.query,
      mood: event.mood,
      date: state.date,
      withPhotosOnly: state.withPhotosOnly,
    ));
  }

  void _onDateFilterChanged(
      DateFilterChanged event, Emitter<SearchState> emit) {
    final filtered = _applyFilters(
      state.allEntries,
      state.query,
      state.mood,
      event.date,
      state.withPhotosOnly,
    );
    emit(SearchState(
      allEntries: state.allEntries,
      filteredEntries: filtered,
      query: state.query,
      mood: state.mood,
      date: event.date,
      withPhotosOnly: state.withPhotosOnly,
    ));
  }

  void _onPhotosFilterToggled(
      PhotosFilterToggled event, Emitter<SearchState> emit) {
    final filtered = _applyFilters(
      state.allEntries,
      state.query,
      state.mood,
      state.date,
      event.withPhotosOnly,
    );
    emit(state.copyWith(
      withPhotosOnly: event.withPhotosOnly,
      filteredEntries: filtered,
    ));
  }

  List<JournalEntry> _applyFilters(
    List<JournalEntry> entries,
    String query,
    String? mood,
    DateTime? date,
    bool withPhotosOnly,
  ) {
    return entries.where((entry) {
      // Text search
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!entry.title.toLowerCase().contains(q) &&
            !entry.content.toLowerCase().contains(q)) {
          return false;
        }
      }
      // Mood filter
      if (mood != null && entry.mood != mood) return false;
      // Date filter
      if (date != null) {
        final eD = DateTime(
            entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        final fD = DateTime(date.year, date.month, date.day);
        if (eD != fD) return false;
      }
      // Photos-only
      if (withPhotosOnly && !entry.attachments.any((a) => a.type == 'image')) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> close() {
    journalSubscription.cancel();
    return super.close();
  }
}
