import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';
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

  final FileStorageService _fileService = FileStorageService();
  final List<Attachment> _attachments = [];
  bool _showTitleError = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.title);
    _contentCtrl = TextEditingController(text: widget.entry.content);
    _attachments.addAll(widget.entry.attachments);
  }

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

        setState(() {
          _attachments.add(
            Attachment(url: savedFile.path, name: file.name, type: type),
          );
        });
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _showTitleError = true);
      return;
    }

    final updatedEntry = widget.entry.copyWith(
      title: title,
      content: content,
      attachments: _attachments,
    );

    context.read<JournalBloc>().add(UpdateEntry(updatedEntry));
    Navigator.of(context).pop();
  }

  Widget _buildAttachmentPreview() {
    if (_attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attachments',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._attachments.asMap().entries.map((entry) {
          final index = entry.key;
          final a = entry.value;
          final isImage = a.type == 'image';
          final file = File(a.url);

          return ListTile(
            leading: isImage
                ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
                : const Icon(Icons.insert_drive_file),
            title: Text(a.name),
            onTap: () => OpenFile.open(a.url),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _removeAttachment(index),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              label: 'Title',
              hint: 'Update title...',
              controller: _titleCtrl,
              errorText: _showTitleError ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Content',
              hint: 'Update your thoughts...',
              controller: _contentCtrl,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Attachment'),
              ),
            ),
            _buildAttachmentPreview(),
            PrimaryButton(label: 'Save Changes', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
