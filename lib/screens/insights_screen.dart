import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:roohbaru_app/models/journal_entry.dart';
import 'package:roohbaru_app/utils/mood_utils.dart';
import '../blocs/Insights/insights_bloc.dart';
import '../blocs/Insights/insights_event.dart';
import '../blocs/Insights/insights_state.dart';
import '../blocs/Journal/journal_bloc.dart';
import '../widgets/insights/duration_selector.dart';
import '../widgets/insights/analytics_card.dart';
import '../widgets/insights/mood_bar_chart.dart';
import '../widgets/insights/mood_donut_chart.dart'; 

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
      backgroundColor: defaultMoodBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: BlocBuilder<InsightsBloc, InsightsState>(
              builder: (ctx, state) {
                final entries =
                    _filteredEntries(state.allEntries, state.durationFilter);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                PhosphorIcons.arrowCircleLeft,
                                size: 32,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Insights',
                              style: TextStyle(
                                fontFamily: 'lufga-bold',
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 1) Duration selector
                      DurationSelector(
                        current: state.durationFilter,
                        onChanged: (f) =>
                            ctx.read<InsightsBloc>().add(DurationChanged(f)),
                      ),

                      const SizedBox(height: 12),

                      // 2) Analytics card
                      AnalyticsCard(
                        title: 'Total Entries',
                        total: state.totalEntries,
                        changePercent: state.changePercent,
                        hasChange: state.hasChange,
                        isIncrease: state.isIncrease,
                      ),

                      const SizedBox(height: 2),

                      // 3) Bar chart
                      SizedBox(
                        height: 300,
                        child: MoodBarChart(
                          data: state.categoryCounts,
                          selectedCategory: null,
                          onCategoryTap: (_) {},
                        ),
                      ),

                      const SizedBox(height: 2),

                      // 4) Pie‐chart breakdown for each category
                      for (final category in [
                        'Positive',
                        'Neutral',
                        'Negative'
                      ]) ...[
                        Builder(builder: (_) {
                          // build only moods with count ≥ 1
                          final breakdown = <String, int>{};
                          for (var m in _moodCategories[category]!) {
                            final cnt =
                                entries.where((e) => e.mood == m).length;
                            if (cnt > 0) breakdown[m] = cnt;
                          }
                          if (breakdown.isEmpty) return const SizedBox.shrink();

                          return Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            margin: const EdgeInsets.only(bottom: 18),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(24),
                            //   color: Colors.white.withOpacity(0.95),
                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: Colors.black.withOpacity(0.08),
                            //       blurRadius: 12,
                            //       spreadRadius: 2,
                            //       offset: const Offset(0, 4),
                            //     ),
                            //   ],
                            // ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.0),
                              // color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    '$category Entries Breakdown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // render the pie chart
                                SizedBox(
                                  height: 300,
                                  child: MoodDonutChart(data: breakdown),
                                ),
                                // SizedBox(
                                //   height: 300,
                                //   child: MoodRadarChart(data: breakdown),
                                // ),
                                // const SizedBox(height: 2),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
