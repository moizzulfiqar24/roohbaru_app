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

  static const _defaultBg = Color(0xFFFFFAF7);

  /// Only these six colours allowed
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
      child: Scaffold(
        body: BlocBuilder<JournalBloc, JournalState>(
          builder: (ctx, journalState) {
            // pick background colour from latest mood
            Color bg = _defaultBg;
            List<JournalEntry> all = [];
            if (journalState is JournalLoaded) {
              all = journalState.entries;
              if (all.isNotEmpty) {
                bg = _moodBgColor[all.first.mood] ?? _defaultBg;
              }
            }

            return Stack(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      // vertical: 2.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // top icons
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onPressed: () {/* later */},
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.search_rounded,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onPressed: () {/* later */},
                              ),
                            ],
                          ),

                          // const SizedBox(height: 8),
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

                          // quote card
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
                                            // fontWeight: FontWeight.w500,
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
                                          fontWeight: FontWeight.bold),
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

                          const SizedBox(height: 24),

                          // journal entries
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
            );
          },
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
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
                      color: Colors.blue),
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

    // only keep images whose file actually exists
    final imgs = e.attachments
        .where((a) => a.type == 'image' && File(a.url).existsSync())
        .map((a) => a.url)
        .toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: e.id)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // date box
                Container(
                  width: 50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(dow,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(dayNum,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(e.content,
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),

            // images row
            if (imgs.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imgs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final file = File(imgs[i]);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image,
                              size: 40, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
