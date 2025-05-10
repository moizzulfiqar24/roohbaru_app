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

  const EntryDetailScreen({super.key, required this.entryId});

  void _editEntry(BuildContext context, JournalEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEntryScreen(entry: entry),
      ),
    );
  }

  void _confirmDelete(BuildContext context, JournalEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      context.read<JournalBloc>().add(DeleteEntry(entry.id));
      Navigator.pop(context); // Exit detail screen after deletion
    }
  }

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
                final match =
                    state.entries.where((e) => e.id == entryId).toList();
                if (match.isEmpty) return;
                _editEntry(context, match.first);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final state = context.read<JournalBloc>().state;
              if (state is JournalLoaded) {
                final match =
                    state.entries.where((e) => e.id == entryId).toList();
                if (match.isEmpty) return;
                _confirmDelete(context, match.first);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state is JournalLoaded) {
            final match = state.entries.where((e) => e.id == entryId).toList();

            if (match.isEmpty) {
              return const Center(child: Text("Entry not found."));
            }

            final entry = match.first;
            final date =
                "${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(date, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Text(entry.content, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  if (entry.attachments.isNotEmpty) ...[
                    const Text(
                      'Attachments',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...entry.attachments.map((a) {
                      final isImage = a.type == 'image';
                      final file = File(a.url);
                      return ListTile(
                        leading: isImage
                            ? Image.file(
                                file,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.insert_drive_file),
                        title: Text(a.name),
                        onTap: () => OpenFile.open(a.url),
                      );
                    }),
                  ],
                ],
              ),
            );
          } else if (state is JournalError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
