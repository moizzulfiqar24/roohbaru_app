// lib/screens/search_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/search_bloc.dart';
import '../blocs/search_event.dart';
import '../blocs/search_state.dart';
import '../models/journal_entry.dart';
import '../utils/mood_utils.dart';
import '../widgets/custom_date_picker.dart'; // ← NEW import
import 'entry_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final journalBloc = context.read<JournalBloc>();
    return BlocProvider<SearchBloc>(
      create: (_) => SearchBloc(journalBloc: journalBloc),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({Key? key}) : super(key: key);

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();

  bool get _hasAnyFilter {
    final s = context.read<SearchBloc>().state;
    return s.query.isNotEmpty ||
        s.mood != null ||
        s.date != null ||
        s.withPhotosOnly;
  }

  void _executeSearch() {
    context.read<SearchBloc>().add(QueryChanged(_searchController.text.trim()));
  }

  void _resetAllFilters() {
    _searchController.clear();
    final bloc = context.read<SearchBloc>();
    bloc.add(QueryChanged(''));
    bloc.add(MoodFilterChanged(null));
    bloc.add(DateFilterChanged(null));
    bloc.add(PhotosFilterToggled(false));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    final state = context.watch<SearchBloc>().state;

    return Scaffold(
      backgroundColor: defaultMoodBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _executeSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search entries...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: TextButton(
                        onPressed: _executeSearch,
                        child: const Text('Search'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filters + Reset
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Mood dropdown
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: state.mood,
                              hint: const Text('All moods'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All moods'),
                                ),
                                ..._SearchOptions.moods.map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m))),
                              ],
                              onChanged: (m) => context
                                  .read<SearchBloc>()
                                  .add(MoodFilterChanged(m)),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Date picker using our custom widget
                          GestureDetector(
                            onTap: () async {
                              final picked = await showCustomDatePicker(
                                context: context,
                                initialDate: state.date ?? DateTime.now(),
                              );
                              context
                                  .read<SearchBloc>()
                                  .add(DateFilterChanged(picked));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                state.date != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(state.date!)
                                    : 'Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Photos-only switch
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Photos only'),
                                Switch(
                                  value: state.withPhotosOnly,
                                  onChanged: (v) => context
                                      .read<SearchBloc>()
                                      .add(PhotosFilterToggled(v)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_hasAnyFilter) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetAllFilters,
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Results list: only show once the user has searched or applied a filter
                Expanded(
                  child: !_hasAnyFilter
                      ? const SizedBox.shrink()
                      : state.filteredEntries.isEmpty
                          ? const Center(child: Text('No entries found.'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.filteredEntries.length,
                              itemBuilder: (ctx, i) {
                                final e = state.filteredEntries[i];
                                return _buildEntryItem(e);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(JournalEntry e) {
    final dow = DateFormat('EEE').format(e.timestamp).toLowerCase();
    final dayNum = DateFormat('d').format(e.timestamp);
    final imgs = e.attachments
        .where((a) => a.type == 'image' && File(a.url).existsSync())
        .map((a) => a.url)
        .toList();

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: e.id))),
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

  String _truncateWords(String text, int limit) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= limit) return text;
    return words.take(limit).join(' ') + '...';
  }
}

class _SearchOptions {
  static const List<String> moods = [
    'Happy',
    'Excited',
    'Calm',
    'Grateful',
    'Loving',
    'Confident',
    'Sad',
    'Angry',
    'Anxious',
    'Lonely',
    'Guilty',
    'Jealous',
    'Confused',
    'Surprised',
    'Bored',
    'Restless',
    'Inspired',
    'Distracted',
  ];
}
