import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../blocs/journal_state.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<JournalBloc>().state;
              if (state is JournalLoaded) {
                final idx = state.entries.indexWhere((e) => e.id == entryId);
                if (idx != -1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditEntryScreen(entry: state.entries[idx]),
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content:
                      const Text('Are you sure you want to delete this entry?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                context.read<JournalBloc>().add(DeleteEntry(entryId));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state is JournalLoaded) {
            final idx = state.entries.indexWhere((e) => e.id == entryId);
            if (idx == -1) {
              return const Center(child: Text("Entry not found."));
            }

            final entry = state.entries[idx];
            final date =
                "${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(date, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Text(entry.content, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  // Attachments
                  if (entry.attachments.isNotEmpty) ...[
                    const Text('Attachments',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...entry.attachments.map((a) {
                      final isImage = a.type == 'image';
                      final file = File(a.url);
                      return ListTile(
                        leading: isImage
                            ? Image.file(file,
                                width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.insert_drive_file),
                        title: Text(a.name),
                        onTap: () => OpenFile.open(a.url),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),

                  // Sentiment (read-only)
                  Text('Sentiment: ${entry.sentiment}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  // Mood (dropdown to override)
                  Row(
                    children: [
                      const Text('Mood: ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      DropdownButton<String>(
                        value: entry.mood.isNotEmpty ? entry.mood : null,
                        hint: const Text('Select Mood'),
                        items: moodOptions
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (newMood) {
                          if (newMood != null) {
                            final overridden = entry.copyWith(mood: newMood);
                            context
                                .read<JournalBloc>()
                                .add(UpdateEntry(overridden));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Suggestions
                  const Text('Suggestions:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...entry.suggestions.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child:
                            Text('• $s', style: const TextStyle(fontSize: 14)),
                      )),
                ],
              ),
            );
          } else if (state is JournalError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
