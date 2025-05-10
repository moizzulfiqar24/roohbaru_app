import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class NewEntryScreen extends StatefulWidget {
  final String userId;
  const NewEntryScreen({super.key, required this.userId});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  final List<Attachment> _attachments = [];
  final FileStorageService _fileService = FileStorageService();

  bool _showTitleError = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withReadStream: false,
    );

    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        if (file.path == null) continue;

        final sourceFile = File(file.path!);
        final savedFile =
            await _fileService.saveFileLocally(sourceFile, file.name);

        final ext = file.extension?.toLowerCase() ?? '';
        String type = 'file';

        if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
          type = 'image';
        } else if (ext == 'pdf') {
          type = 'pdf';
        }

        _attachments.add(Attachment(
          url: savedFile.path,
          name: file.name,
          type: type,
        ));
      }

      setState(() {});
    }
  }

  void _submitEntry(BuildContext context) {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }

    final entry = JournalEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: title,
      content: content,
      timestamp: DateTime.now(),
      attachments: _attachments,
    );

    context.read<JournalBloc>().add(AddEntry(entry));
    Navigator.of(context).pop();
  }

  Widget _buildAttachmentPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _attachments.map((a) {
        final isImage = a.type == 'image';
        return ListTile(
          leading: isImage
              ? Image.file(File(a.url),
                  width: 40, height: 40, fit: BoxFit.cover)
              : const Icon(Icons.insert_drive_file, size: 32),
          title: Text(a.name),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                label: 'Title',
                hint: 'Give it a title...',
                controller: _titleCtrl,
                errorText: _showTitleError ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Content',
                hint: 'Write your thoughts...',
                controller: _contentCtrl,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Attachment'),
                ),
              ),
              if (_attachments.isNotEmpty) _buildAttachmentPreview(),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Entry',
                onPressed: () => _submitEntry(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
