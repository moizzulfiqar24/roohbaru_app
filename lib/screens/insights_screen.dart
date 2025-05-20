// lib/screens/insights_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roohbaru_app/models/journal_entry.dart';

import '../blocs/insights_bloc.dart';
import '../blocs/insights_event.dart';
import '../blocs/insights_state.dart';
import '../blocs/journal_bloc.dart';
import '../widgets/insights/duration_selector.dart';
import '../widgets/insights/analytics_card.dart';
import '../widgets/insights/mood_bar_chart.dart';
import '../widgets/insights/mood_pie_chart.dart'; // ← NEW

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InsightsBloc(journalBloc: context.read<JournalBloc>()),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  // same buckets as in the bloc
  static const Map<String, List<String>> _moodCategories = {
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

  // replicate the bloc’s filter logic
  List<JournalEntry> _filteredEntries(
      List<JournalEntry> all, DurationFilter f) {
    if (f == DurationFilter.allTime) return all;
    final now = DateTime.now();
    final days = f == DurationFilter.last30Days ? 30 : 7;
    final cutoff = now.subtract(Duration(days: days));
    return all.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        leading: const BackButton(),
      ),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (ctx, state) {
          final entries =
              _filteredEntries(state.allEntries, state.durationFilter);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1) Duration selector
                DurationSelector(
                  current: state.durationFilter,
                  onChanged: (f) =>
                      ctx.read<InsightsBloc>().add(DurationChanged(f)),
                ),

                const SizedBox(height: 24),

                // 2) Analytics card
                AnalyticsCard(
                  title: 'Entries',
                  total: state.totalEntries,
                  changePercent: state.changePercent,
                  hasChange: state.hasChange,
                  isIncrease: state.isIncrease,
                ),

                const SizedBox(height: 24),

                // 3) Bar chart
                SizedBox(
                  height: 260,
                  child: MoodBarChart(
                    data: state.categoryCounts,
                    selectedCategory: null,
                    onCategoryTap: (_) {},
                  ),
                ),

                const SizedBox(height: 32),

                // 4) Pie‐chart breakdown for each category
                for (final category in ['Positive', 'Neutral', 'Negative']) ...[
                  Builder(builder: (_) {
                    // build only moods with count ≥ 1
                    final breakdown = <String, int>{};
                    for (var m in _moodCategories[category]!) {
                      final cnt = entries.where((e) => e.mood == m).length;
                      if (cnt > 0) breakdown[m] = cnt;
                    }
                    if (breakdown.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // render the pie chart
                        SizedBox(
                          height: 200,
                          child: MoodPieChart(data: breakdown),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
