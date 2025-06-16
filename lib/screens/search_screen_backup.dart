import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/Auth/auth_bloc.dart';
import '../blocs/Auth/auth_state.dart';
import '../blocs/Journal/journal_bloc.dart';
import '../blocs/Search/search_bloc.dart';
import '../blocs/Search/search_event.dart';
import '../models/journal_entry.dart';
import '../utils/mood_utils.dart';
import '../widgets/custom_date_picker.dart';
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

                // Redesigned Search field and button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _executeSearch(),
                            style: const TextStyle(
                              fontFamily: 'lufga-regular',
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search entries...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontFamily: 'lufga-regular',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: _executeSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E2A1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontFamily: 'lufga-semi-bold',
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child: const Text('Search'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Redesigned Filters + Reset
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Mood dropdown
                          Flexible(
                            flex: 2,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String?>(
                                value: state.mood,
                                hint: const Text(
                                  'All moods',
                                  style: TextStyle(
                                    fontFamily: 'lufga-regular',
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'All moods',
                                      style: TextStyle(
                                        fontFamily: 'lufga-regular',
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ..._SearchOptions.moods
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(
                                              m,
                                              style: const TextStyle(
                                                fontFamily: 'lufga-regular',
                                                color: Color(0xFF1A1A1A),
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                ],
                                onChanged: (m) => context
                                    .read<SearchBloc>()
                                    .add(MoodFilterChanged(m)),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          // Date picker
                          Flexible(
                            flex: 1,
                            child: GestureDetector(
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
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.date != null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(state.date!)
                                            : 'Select Date',
                                        style: TextStyle(
                                          fontFamily: 'lufga-regular',
                                          fontSize: 14,
                                          color: state.date != null
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.grey.shade500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Photos-only switch
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Photos only',
                                        style: TextStyle(
                                          fontFamily: 'lufga-regular',
                                          fontSize: 14,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: state.withPhotosOnly,
                                    onChanged: (v) => context
                                        .read<SearchBloc>()
                                        .add(PhotosFilterToggled(v)),
                                    activeColor: const Color(0xFF2E2A1F),
                                    inactiveThumbColor: Colors.grey.shade400,
                                    inactiveTrackColor: Colors.grey.shade200,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_hasAnyFilter) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetAllFilters,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2E2A1F),
                              backgroundColor: Colors.white.withOpacity(0.92),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'lufga-semi-bold',
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child: const Text('Reset Filters'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Results list
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
