import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class NewEntryScreen extends StatefulWidget {
  final String userId;
  const NewEntryScreen({super.key, required this.userId});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      return;
    }

    final entry = JournalEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<JournalBloc>().add(AddEntry(entry));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              label: 'Title',
              hint: 'Give it a title...',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Content',
              hint: 'Write your thoughts...',
              controller: _contentCtrl,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save Entry', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
