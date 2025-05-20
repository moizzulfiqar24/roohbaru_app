import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:roohbaru_app/widgets/suggestion_card.dart';

import '../utils/mood_utils.dart';
import '../blocs/journal_bloc.dart';
import '../blocs/journal_state.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import 'edit_entry_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  final String entryId;
  const EntryDetailScreen({Key? key, required this.entryId}) : super(key: key);

  static const List<String> moodOptions = [
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        if (state is JournalLoaded) {
          final idx = state.entries.indexWhere((e) => e.id == entryId);
          if (idx == -1) {
            return Scaffold(
              backgroundColor: defaultMoodBackground,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final entry = state.entries[idx];
          final bgColor =
              moodBackgroundColors[entry.mood] ?? defaultMoodBackground;
          final dateStr =
              '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}';

          return Scaffold(
            backgroundColor: bgColor,
            body: Stack(
              children: [
                Positioned.fill(
                  child:
                      Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Top bar (back, edit, delete) – unchanged
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditEntryScreen(entry: entry),
                                  ),
                                );
                              },
                              child: const Icon(
                                PhosphorIcons.pencilSimple,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Entry'),
                                    content: const Text(
                                        'Are you sure you want to delete this entry?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  context
                                      .read<JournalBloc>()
                                      .add(DeleteEntry(entryId));
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(
                                PhosphorIcons.trash,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title, date, mood selector, body, images – unchanged
                              Text(
                                entry.title.toLowerCase(),
                                style: const TextStyle(
                                  fontFamily: 'lufga-bold-italic',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Color(0xFF473623),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/mood.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: moodOptions.contains(entry.mood)
                                            ? entry.mood
                                            : null,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(
                                          fontFamily: 'lufga-light',
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        items: moodOptions
                                            .map((m) => DropdownMenuItem(
                                                  value: m,
                                                  child: Text(m),
                                                ))
                                            .toList(),
                                        onChanged: (newMood) {
                                          if (newMood != null) {
                                            final updated =
                                                entry.copyWith(mood: newMood);
                                            context
                                                .read<JournalBloc>()
                                                .add(UpdateEntry(updated));
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                entry.content,
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'lufga-regular'),
                              ),
                              const SizedBox(height: 16),
                              if (entry.attachments.any((a) =>
                                  a.type == 'image' &&
                                  File(a.url).existsSync())) ...[
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: entry.attachments.length,
                                    itemBuilder: (ctx, i) {
                                      final a = entry.attachments[i];
                                      if (a.type == 'image' &&
                                          File(a.url).existsSync()) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: GestureDetector(
                                            onTap: () => OpenFile.open(a.url),
                                            child: Image.file(
                                              File(a.url),
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                              // Refined Separator
                              Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.9),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 2),

                              // Suggestions Section
                              const Text(
                                'Suggestions',
                                style: TextStyle(
                                  fontFamily: 'lufga-bold',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SuggestionCard(
                                  icon: PhosphorIcons.musicNote,
                                  suggestion: entry.suggestions.isNotEmpty
                                      ? entry.suggestions[0]
                                      : 'No music suggestion available',
                                  context: context),
                              const SizedBox(height: 8),
                              SuggestionCard(
                                  icon: PhosphorIcons.filmStrip,
                                  suggestion: entry.suggestions.length > 1
                                      ? entry.suggestions[1]
                                      : 'No movie suggestion available',
                                  context: context),

                              // AI Analysis Section
                              const SizedBox(height: 12),
                              const Text(
                                'AI Insights',
                                style: TextStyle(
                                  fontFamily: 'lufga-bold',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.3),
                                  color:
                                      const Color(0xFF2E2E2E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  entry.analysis.isNotEmpty
                                      ? entry.analysis
                                      : 'No AI insights available at this time.',
                                  style: const TextStyle(
                                    fontFamily: 'lufga-regular',
                                    fontSize: 15,
                                    color: Color(0xFF4A4A4A),
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Loading / Error
        return Scaffold(
          backgroundColor: defaultMoodBackground,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
