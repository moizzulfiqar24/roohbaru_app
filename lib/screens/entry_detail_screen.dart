// lib/screens/entry_detail_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';

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
            // still loading entry
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
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Top bar: back, spacer, share, edit, delete
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.arrow_back,
                                  size: 28, color: Colors.black),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                // TODO: share logic
                              },
                              child: const Icon(PhosphorIcons.shareNetwork,
                                  size: 28, color: Colors.black),
                            ),
                            const SizedBox(width: 16),
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
                              child: const Icon(PhosphorIcons.pencilSimple,
                                  size: 28, color: Colors.black),
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
                              child: const Icon(PhosphorIcons.trash,
                                  size: 28, color: Colors.black),
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
                              // Title
                              Text(
                                entry.title.toLowerCase(),
                                style: const TextStyle(
                                  fontFamily: 'lufga-bold-italic',
                                  // color: Color(0xFF473623),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Date
                              Text(
                                dateStr,
                                style: TextStyle(
                                  // color: Colors.grey[600],
                                  color: Color(0xFF473623),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Mood selector: icon then dropdown container
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
                                          Icons.keyboard_arrow_down,
                                          // PhosphorIcons.caretDown,
                                        ),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(
                                          fontFamily: 'lufga-light',
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        items: moodOptions.map((m) {
                                          return DropdownMenuItem<String>(
                                            value: m,
                                            child: Text(
                                              m,
                                              style: const TextStyle(
                                                fontFamily: 'lufga-light',
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        }).toList(),
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
                              // Body
                              Text(
                                entry.content,
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'lufga-regular'),
                              ),
                              const SizedBox(height: 16),
                              // Image attachments preview
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
                                const SizedBox(height: 16),
                              ],
                              const Divider(color: Colors.black),
                              const SizedBox(height: 16),
                              // Suggestions
                              const Text('Suggestions',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    // Icons.music_note,
                                    PhosphorIcons.musicNote,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.suggestions.isNotEmpty
                                          ? entry.suggestions[0]
                                          : '',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    // Icons.movie,
                                    PhosphorIcons.filmStrip,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.suggestions.length > 1
                                          ? entry.suggestions[1]
                                          : '',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
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

        // loading / error
        return Scaffold(
          backgroundColor: defaultMoodBackground,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
