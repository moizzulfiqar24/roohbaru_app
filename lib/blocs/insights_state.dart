// lib/blocs/insights_state.dart
import 'package:equatable/equatable.dart';
import 'package:roohbaru_app/models/journal_entry.dart';
import '../blocs/insights_event.dart';

class InsightsState extends Equatable {
  final List<JournalEntry> allEntries;
  final DurationFilter durationFilter;
  final int totalEntries;
  final double changePercent;
  final bool hasChange; // false for allTime
  final bool isIncrease; // true if +, false if –
  final Map<String, int> categoryCounts; // { 'Positive': 10, ... }
  final String? selectedCategory; // which bar was tapped
  final Map<String, int> moodBreakdownCounts; // per-mood in selected category

  const InsightsState({
    required this.allEntries,
    required this.durationFilter,
    required this.totalEntries,
    required this.changePercent,
    required this.hasChange,
    required this.isIncrease,
    required this.categoryCounts,
    required this.selectedCategory,
    required this.moodBreakdownCounts,
  });

  factory InsightsState.initial() {
    return InsightsState(
      allEntries: [],
      durationFilter: DurationFilter.allTime,
      totalEntries: 0,
      changePercent: 0,
      hasChange: false,
      isIncrease: true,
      categoryCounts: const {'Positive': 0, 'Neutral': 0, 'Negative': 0},
      selectedCategory: null,
      moodBreakdownCounts: const {},
    );
  }

  InsightsState copyWith({
    List<JournalEntry>? allEntries,
    DurationFilter? durationFilter,
    int? totalEntries,
    double? changePercent,
    bool? hasChange,
    bool? isIncrease,
    Map<String, int>? categoryCounts,
    String? selectedCategory, // pass null to clear
    Map<String, int>? moodBreakdownCounts,
  }) {
    return InsightsState(
      allEntries: allEntries ?? this.allEntries,
      durationFilter: durationFilter ?? this.durationFilter,
      totalEntries: totalEntries ?? this.totalEntries,
      changePercent: changePercent ?? this.changePercent,
      hasChange: hasChange ?? this.hasChange,
      isIncrease: isIncrease ?? this.isIncrease,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      selectedCategory: selectedCategory,
      moodBreakdownCounts: moodBreakdownCounts ?? this.moodBreakdownCounts,
    );
  }

  @override
  List<Object?> get props => [
        allEntries,
        durationFilter,
        totalEntries,
        changePercent,
        hasChange,
        isIncrease,
        categoryCounts,
        selectedCategory,
        moodBreakdownCounts,
      ];
}
