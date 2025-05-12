// lib/screens/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../blocs/journal_state.dart';
import '../models/journal_entry.dart';
import 'intro_screen.dart';
import 'new_entry_screen.dart';
import 'entry_detail_screen.dart';

enum ViewMode { day, week }

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ViewMode _viewMode = ViewMode.day;
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(LoadEntries(widget.user.uid));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Start of the week (Monday) at midnight
  DateTime get _weekStart {
    final today =
        DateTime(_focusedDate.year, _focusedDate.month, _focusedDate.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  /// End of the week (Sunday) at midnight
  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  // Mood → icon
  static const _moodIcons = {
    'Happy': Icons.sentiment_satisfied_alt,
    'Excited': Icons.emoji_emotions,
    'Calm': Icons.self_improvement,
    'Grateful': Icons.favorite,
    'Loving': Icons.favorite,
    'Confident': Icons.thumb_up,
    'Sad': Icons.sentiment_dissatisfied,
    'Angry': Icons.sentiment_very_dissatisfied,
    'Anxious': Icons.sentiment_neutral,
    'Lonely': Icons.mood_bad,
    'Guilty': Icons.sentiment_very_dissatisfied,
    'Jealous': Icons.sentiment_dissatisfied,
    'Confused': Icons.help_outline,
    'Surprised': Icons.emoji_objects,
    'Bored': Icons.hourglass_empty,
    'Restless': Icons.bolt,
    'Inspired': Icons.lightbulb,
    'Distracted': Icons.blur_on,
  };

  IconData _iconFor(String mood) => _moodIcons[mood] ?? Icons.sentiment_neutral;

  // Mood → gradient
  static const _moodGradients = {
    'Happy': [Color(0xFFFFD1F0), Color(0xFFFF9FDD)],
    'Excited': [Color(0xFFFFE29A), Color(0xFFFFA97A)],
    'Calm': [Color(0xFFB8E0FF), Color(0xFF81C3EB)],
    'Grateful': [Color(0xFFFFE8A1), Color(0xFFFFC97A)],
    'Loving': [Color(0xFFFFC1E3), Color(0xFFFBA3C1)],
    'Confident': [Color(0xFFB5FFD9), Color(0xFF6CE7C5)],
    'Sad': [Color(0xFFB0BEC5), Color(0xFF78909C)],
    'Angry': [Color(0xFFFF8A80), Color(0xFFD32F2F)],
    'Anxious': [Color(0xFFE0BBE4), Color(0xFF957DAD)],
    'Lonely': [Color(0xFF90CAF9), Color(0xFF42A5F5)],
    'Guilty': [Color(0xFFD3CCE3), Color(0xFFE9E4F0)],
    'Jealous': [Color(0xFFB9F6CA), Color(0xFF69F0AE)],
    'Confused': [Color(0xFFFFF59D), Color(0xFFFFEB3B)],
    'Surprised': [Color(0xFFFFF59D), Color(0xFFFFE57F)],
    'Bored': [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
    'Restless': [Color(0xFFFFF176), Color(0xFFFFEE58)],
    'Inspired': [Color(0xFFCCFF90), Color(0xFFB2FF59)],
    'Distracted': [Color(0xFFCFD8DC), Color(0xFFB0BEC5)],
  };

  LinearGradient _gradientFor(String mood) {
    final cols =
        _moodGradients[mood] ?? [Colors.grey.shade300, Colors.grey.shade400];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cols,
    );
  }

  String _fmtMonthDay(DateTime d) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${names[d.month]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.displayName ?? widget.user.email ?? 'User';

    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, st) {
        if (st is AuthUnauthenticated) {
          Navigator.of(ctx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const IntroScreen()),
            (_) => false,
          );
        } else if (st is AuthError) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(st.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: Text('Roohbaru — Hi, $name'),
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.logout, color: Colors.black87),
        //       onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
        //     )
        //   ],
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NewEntryScreen(userId: widget.user.uid)),
          ),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<JournalBloc, JournalState>(
          builder: (ctx, journalState) {
            // grab all entries
            final entries = journalState is JournalLoaded
                ? journalState.entries
                : <JournalEntry>[];

            // filter & sort
            List<JournalEntry> filtered;
            if (_viewMode == ViewMode.day) {
              filtered = entries
                  .where((e) => _sameDay(e.timestamp, _focusedDate))
                  .toList();
            } else {
              final start = _weekStart;
              final end = _weekEnd;
              filtered = entries.where((e) {
                final d = DateTime(
                    e.timestamp.year, e.timestamp.month, e.timestamp.day);
                return d.compareTo(start) >= 0 && d.compareTo(end) <= 0;
              }).toList();
            }
            filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            // header gradient from first entry
            final headerGrad = filtered.isNotEmpty
                ? _gradientFor(filtered.first.mood)
                : const LinearGradient(
                    colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
                  );

            return Column(
              children: [
                // TOP AREA
                Container(
                  decoration: BoxDecoration(
                    gradient: headerGrad,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Title, toggle, search
                          Row(
                            children: [
                              const Text(
                                'Journal',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildToggle('Day', ViewMode.day),
                                    _buildToggle('Week', ViewMode.week),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<AuthBloc>()
                                          .add(SignOutRequested());
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_viewMode == ViewMode.day)
                            _buildDaySlider()
                          else
                            _buildWeekPicker(),
                        ],
                      ),
                    ),
                  ),
                ),
                // ENTRY LIST
                Expanded(
                  child: () {
                    if (journalState is JournalLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (journalState is JournalError) {
                      return Center(child: Text(journalState.message));
                    }
                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('No entries for this period.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildEntryCard(filtered[i]),
                    );
                  }(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggle(String label, ViewMode mode) {
    final selected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDaySlider() {
    final start = _weekStart;
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: days.map((d) {
            final sel = _sameDay(d, _focusedDate);
            return GestureDetector(
              onTap: () => setState(() => _focusedDate = d),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      d.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sel ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ][d.weekday - 1],
                      style: TextStyle(
                        fontSize: 12,
                        color: sel ? Colors.white : Colors.black54,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeekPicker() {
    final start = _weekStart;
    final end = _weekEnd;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () => setState(
                () => _focusedDate = start.subtract(const Duration(days: 1))),
          ),
          const SizedBox(width: 8),
          Text(
            '${_fmtMonthDay(start)} - ${_fmtMonthDay(end)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            onPressed: () =>
                setState(() => _focusedDate = end.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry e) {
    final grad = _gradientFor(e.mood);
    final icon = _iconFor(e.mood);
    final hasAttach = e.attachments.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: e.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (hasAttach) const Icon(Icons.attach_file, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(e.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16),
                    const SizedBox(width: 4),
                    Text(e.mood, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
