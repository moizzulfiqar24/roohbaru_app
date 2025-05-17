// lib/screens/home_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../blocs/journal_state.dart';
import '../models/journal_entry.dart';
import '../services/quote_service.dart';
import '../widgets/navbar.dart';
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
  int _selectedIndex = 0;

  // static const _defaultBg = Color(0xFFFFFAF7);
  static const _defaultBg = Color(0xFFf8eed5);

  static const Map<String, Color> _moodBgColor = {
    'Happy': Color(0xFFAADAF0),
    'Excited': Color(0xFFD6D3F9),
    'Calm': Color(0xFF7FD1AE),
    'Grateful': Color(0xFFF1DEAC),
    'Loving': Color(0xFFF5C8CB),
    'Confident': Color(0xFFFFC5A6),
    'Sad': Color(0xFFF5C8CB),
    'Angry': Color(0xFFFFC5A6),
    'Anxious': Color(0xFFD6D3F9),
    'Lonely': Color(0xFFAADAF0),
    'Guilty': Color(0xFFF1DEAC),
    'Jealous': Color(0xFF7FD1AE),
    'Confused': Color(0xFFD6D3F9),
    'Surprised': Color(0xFFAADAF0),
    'Bored': Color(0xFFF1DEAC),
    'Restless': Color(0xFFFFC5A6),
    'Inspired': Color(0xFF7FD1AE),
    'Distracted': Color(0xFFD6D3F9),
  };

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

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
      child: BlocBuilder<JournalBloc, JournalState>(
        builder: (ctx, journalState) {
          Color bg = _defaultBg;
          List<JournalEntry> all = [];
          if (journalState is JournalLoaded) {
            all = journalState.entries;
            if (all.isNotEmpty) {
              bg = _moodBgColor[all.first.mood] ?? _defaultBg;
            }
          }

          return Scaffold(
            backgroundColor: bg,
            body: Stack(
              children: [
                Container(color: bg),
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onPressed: () {},
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  size: 25,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(SignOutRequested());
                                },
                              ),
                            ],
                          ),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _greeting,
                                  style: const TextStyle(
                                    fontFamily: 'lufga-bold',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'reflect, grow, thrive',
                                  style: TextStyle(
                                    fontFamily: 'lufga-regular',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<Quote>(
                            future: _quoteFuture,
                            builder: (c, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snap.hasError) {
                                return Text(
                                  'Error loading quote',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              final q = snap.data!;
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text(
                                          "today’s quote",
                                          style: TextStyle(
                                            fontFamily: 'lufga-regular',
                                            fontSize: 18,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Icon(
                                          Icons.format_quote_rounded,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.text.toLowerCase(),
                                      style: const TextStyle(
                                        fontFamily: 'lufga-light-italic',
                                        fontSize: 20,
                                        color: Color(0xFF473623),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '- ${q.author}',
                                      style: const TextStyle(
                                        fontFamily: 'lufga-semi-bold',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          if (journalState is JournalLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (journalState is JournalError)
                            Center(child: Text(journalState.message))
                          else if (all.isEmpty)
                            const Center(child: Text('No entries yet.'))
                          else
                            ..._buildMonthlySections(all),
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
                selectedIndex: _selectedIndex,
                onItemSelected: _onItemSelected,
                onAddPressed: _onAddPressed,
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMonthlySections(List<JournalEntry> all) {
    final Map<DateTime, List<JournalEntry>> byMonth = {};
    for (var e in all) {
      final key = DateTime(e.timestamp.year, e.timestamp.month);
      byMonth.putIfAbsent(key, () => []).add(e);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    final List<Widget> sections = [];
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewEntryScreen(userId: widget.user.uid),
                  ),
                ),
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
                                errorBuilder: (ctx, err, stack) => Container(
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
