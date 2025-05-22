// lib/screens/home_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:roohbaru_app/screens/insights_screen.dart';
import 'package:roohbaru_app/screens/profile_screen.dart';
import 'package:roohbaru_app/screens/search_screen.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../blocs/journal_state.dart';
import '../blocs/home_ui_bloc.dart';
import '../blocs/home_ui_event.dart';
import '../blocs/home_ui_state.dart';
import '../models/journal_entry.dart';
import '../services/quote_service.dart';
import '../utils/mood_utils.dart';
import '../widgets/home/navbar.dart';
import '../widgets/home/header_row.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/quote_section.dart';
import '../widgets/custom_date_picker.dart'; // ← NEW import
import 'intro_screen.dart';
import 'new_entry_screen.dart';
import 'entry_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Quote> _quoteFuture;
  static const _defaultBg = defaultMoodBackground;

  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(LoadEntries(widget.user.uid));
    _quoteFuture = QuoteService.fetchTodayQuote();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'good morning';
    if (h < 17) return 'good afternoon';
    return 'good evening';
  }

  String _truncateWords(String text, int limit) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= limit) return text;
    return words.take(limit).join(' ') + '...';
  }

  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewEntryScreen(userId: widget.user.uid),
      ),
    );
  }

  void _onItemSelected(int index, BuildContext innerCtx) {
    if (index == 1) {
      Navigator.push(
          innerCtx, MaterialPageRoute(builder: (_) => const SearchScreen()));
    } else if (index == 2) {
      Navigator.push(
          innerCtx, MaterialPageRoute(builder: (_) => const InsightsScreen()));
    } else if (index == 3) {
      Navigator.push(
          innerCtx, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    } else {
      innerCtx.read<HomeUiBloc>().add(SelectTab(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeUiBloc>(
      create: (_) => HomeUiBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, st) {
          if (st is AuthUnauthenticated) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const IntroScreen()),
              (_) => false,
            );
          } else if (st is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(st.message)),
            );
          }
        },
        child: BlocBuilder<JournalBloc, JournalState>(
          builder: (journalCtx, journalState) {
            // use the inner context (journalCtx) for reading HomeUiBloc
            final uiState = journalCtx.watch<HomeUiBloc>().state;
            final selectedIndex = uiState.selectedIndex;
            final selectedDate = uiState.selectedDate;

            Color bg = _defaultBg;
            List<JournalEntry> all = [];
            if (journalState is JournalLoaded) {
              all = journalState.entries;
              if (all.isNotEmpty) {
                bg = moodBackgroundColors[all.first.mood] ?? _defaultBg;
              }
            }

            return Scaffold(
              backgroundColor: bg,
              body: Stack(
                children: [
                  Container(color: bg),
                  Positioned.fill(
                    child:
                        Image.asset('assets/images/bg.png', fit: BoxFit.cover),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeaderRow(
                              onCalendarPressed: () async {
                                final picked = await showCustomDatePicker(
                                  context: journalCtx,
                                  initialDate: selectedDate ?? DateTime.now(),
                                );
                                if (picked != null) {
                                  journalCtx
                                      .read<HomeUiBloc>()
                                      .add(PickDate(picked));
                                }
                              },
                              isDateSelected: selectedDate != null,
                              onReset: () => journalCtx
                                  .read<HomeUiBloc>()
                                  .add(const ResetDate()),
                              onLogoutPressed: () => journalCtx
                                  .read<AuthBloc>()
                                  .add(SignOutRequested()),
                            ),
                            GreetingSection(greeting: _greeting),
                            const SizedBox(height: 24),
                            QuoteSection(quoteFuture: _quoteFuture),
                            const SizedBox(height: 6),
                            if (journalState is JournalLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (journalState is JournalError)
                              Center(child: Text(journalState.message))
                            else if (all.isEmpty)
                              const Center(child: Text('No entries yet.'))
                            else
                              ..._buildMonthlySections(all, selectedDate),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Container(
                color: bg,
                child: CustomNavbar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (i) => _onItemSelected(i, journalCtx),
                  onAddPressed: _onAddPressed,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildMonthlySections(
      List<JournalEntry> all, DateTime? selectedDate) {
    if (selectedDate != null) {
      final filtered = all.where((e) {
        final d = e.timestamp;
        return d.year == selectedDate.year &&
            d.month == selectedDate.month &&
            d.day == selectedDate.day;
      }).toList();

      final label = DateFormat('d MMM yyyy').format(selectedDate).toLowerCase();

      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'lufga-bold',
                  color: Color(0xFF473623),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _onAddPressed,
                child: const Text(
                  '+ add new',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (var e in filtered) _buildEntryItem(e),
      ];
    }

    final byMonth = <DateTime, List<JournalEntry>>{};
    for (var e in all) {
      final key = DateTime(e.timestamp.year, e.timestamp.month);
      byMonth.putIfAbsent(key, () => []).add(e);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    final sections = <Widget>[];
    for (var month in months) {
      final label = DateFormat('MMMM yyyy').format(month);
      final entries = byMonth[month]!
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
          child: Row(
            children: [
              Text(
                label.toLowerCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'lufga-bold',
                  color: Color(0xFF473623),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _onAddPressed,
                child: const Text(
                  '+ add new',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      for (var e in entries) {
        sections.add(_buildEntryItem(e));
      }
    }
    return sections;
  }

  Widget _buildEntryItem(JournalEntry e) {
    final dow = DateFormat('EEE').format(e.timestamp).toLowerCase();
    final dayNum = DateFormat('d').format(e.timestamp);
    final imgs = e.attachments
        .where((a) => a.type == 'image' && File(a.url).existsSync())
        .map((a) => a.url)
        .toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: e.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    dow,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'lufga-semi-bold',
                      color: Color(0xFF473623),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'lufga-regular',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title.toLowerCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'lufga-semi-bold-italic',
                      color: Color(0xFF473623),
                    ),
                  ),
                  Text(
                    _truncateWords(e.content, 30).toLowerCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontFamily: 'lufga-regular',
                    ),
                  ),
                  if (imgs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: imgs.take(2).map((path) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
