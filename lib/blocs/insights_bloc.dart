// lib/blocs/insights_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/journal_entry.dart';
import 'journal_bloc.dart';
import 'journal_state.dart';
import 'insights_event.dart';
import 'insights_state.dart';

/// Helper to bundle metric results.
class _Metrics {
  final int total;
  final double percent;
  final bool hasChange;
  final bool isIncrease;
  _Metrics(this.total, this.percent, this.hasChange, this.isIncrease);
}

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final JournalBloc journalBloc;
  late final StreamSubscription _journalSub;

  /// Define which moods go in which bucket.
  static const Map<String, List<String>> moodCategories = {
    'Positive': [
      'Happy',
      'Excited',
      'Calm',
      'Grateful',
      'Loving',
      'Confident',
      'Inspired'
    ],
    'Neutral': ['Surprised', 'Bored', 'Distracted'],
    'Negative': [
      'Sad',
      'Angry',
      'Anxious',
      'Lonely',
      'Guilty',
      'Jealous',
      'Confused',
      'Restless'
    ],
  };

  InsightsBloc({required this.journalBloc}) : super(InsightsState.initial()) {
    // 1) Handlers
    on<EntriesUpdated>(_onEntriesUpdated);
    on<DurationChanged>(_onDurationChanged);
    on<CategorySelected>(_onCategorySelected);

    // 2) Seed initial if already loaded
    if (journalBloc.state is JournalLoaded) {
      add(EntriesUpdated((journalBloc.state as JournalLoaded).entries));
    }

    // 3) Subscribe for future journal updates
    _journalSub = journalBloc.stream.listen((js) {
      if (js is JournalLoaded) add(EntriesUpdated(js.entries));
    });
  }

  void _onEntriesUpdated(EntriesUpdated event, Emitter<InsightsState> emit) {
    // Always recompute everything based on current filter
    final now = DateTime.now();
    final metrics = _computeMetrics(event.entries, state.durationFilter, now);
    final filtered = _filterEntries(event.entries, state.durationFilter, now);
    final categories = _computeCategoryCounts(filtered);

    emit(state.copyWith(
      allEntries: event.entries,
      totalEntries: metrics.total,
      changePercent: metrics.percent,
      hasChange: metrics.hasChange,
      isIncrease: metrics.isIncrease,
      categoryCounts: categories,
      selectedCategory: null,
      moodBreakdownCounts: {},
    ));
  }

  void _onDurationChanged(DurationChanged event, Emitter<InsightsState> emit) {
    final now = DateTime.now();
    final metrics = _computeMetrics(state.allEntries, event.filter, now);
    final filtered = _filterEntries(state.allEntries, event.filter, now);
    final categories = _computeCategoryCounts(filtered);

    emit(state.copyWith(
      durationFilter: event.filter,
      totalEntries: metrics.total,
      changePercent: metrics.percent,
      hasChange: metrics.hasChange,
      isIncrease: metrics.isIncrease,
      categoryCounts: categories,
      selectedCategory: null,
      moodBreakdownCounts: {},
    ));
  }

  void _onCategorySelected(
      CategorySelected event, Emitter<InsightsState> emit) {
    final now = DateTime.now();
    final filtered =
        _filterEntries(state.allEntries, state.durationFilter, now);
    final moods = moodCategories[event.category]!;
    final breakdown = <String, int>{};
    for (var m in moods) {
      breakdown[m] = filtered.where((e) => e.mood == m).length;
    }

    emit(state.copyWith(
      selectedCategory: event.category,
      moodBreakdownCounts: breakdown,
    ));
  }

  // Helpers:

  List<JournalEntry> _filterEntries(
    List<JournalEntry> all,
    DurationFilter f,
    DateTime now,
  ) {
    if (f == DurationFilter.allTime) return all;
    final cutoff =
        now.subtract(Duration(days: f == DurationFilter.last30Days ? 30 : 7));
    return all.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  _Metrics _computeMetrics(
    List<JournalEntry> all,
    DurationFilter f,
    DateTime now,
  ) {
    if (f == DurationFilter.allTime) {
      return _Metrics(all.length, 0, false, true);
    }

    // current window
    final days = f == DurationFilter.last30Days ? 30 : 7;
    final start = now.subtract(Duration(days: days));
    final current = all.where((e) => e.timestamp.isAfter(start)).length;

    // previous window
    final prevStart = now.subtract(Duration(days: days * 2));
    final previous = all
        .where((e) =>
            e.timestamp.isAfter(prevStart) && e.timestamp.isBefore(start))
        .length;

    if (previous == 0) {
      final percent = current == 0 ? 0 : 100.0;
      return _Metrics(current, percent.toDouble(), current > 0, true);
    }

    final diff = current - previous;
    final pct = diff / previous * 100;
    return _Metrics(current, pct.abs(), true, diff >= 0);
  }

  Map<String, int> _computeCategoryCounts(List<JournalEntry> filtered) {
    final map = <String, int>{};
    for (var cat in moodCategories.keys) {
      map[cat] =
          filtered.where((e) => moodCategories[cat]!.contains(e.mood)).length;
    }
    return map;
  }

  @override
  Future<void> close() {
    _journalSub.cancel();
    return super.close();
  }
}
