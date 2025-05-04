import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.title);
    _contentCtrl = TextEditingController(text: widget.entry.content);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final updatedEntry = JournalEntry(
      id: widget.entry.id,
      userId: widget.entry.userId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<JournalBloc>().add(UpdateEntry(updatedEntry));
    Navigator.of(context).pop(); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              label: 'Title',
              hint: 'Update title...',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Content',
              hint: 'Update your thoughts...',
              controller: _contentCtrl,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save Changes', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
