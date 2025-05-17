// lib/screens/edit_entry_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  const EditEntryScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  final FileStorageService _fileService = FileStorageService();
  final ImagePicker _picker = ImagePicker();
  late List<Attachment> _attachments;
  bool _showTitleError = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.title);
    _contentCtrl = TextEditingController(text: widget.entry.content);
    _attachments = List.from(widget.entry.attachments);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (picked == null) return;

      for (var xfile in picked) {
        final File src = File(xfile.path);
        final saved = await _fileService.saveImageLocally(src);
        setState(() {
          _attachments.add(
            Attachment(
              url: saved.path,
              name: xfile.name,
              type: 'image',
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
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

    final updated = widget.entry.copyWith(
      title: title,
      content: content,
      attachments: _attachments,
    );

    context.read<JournalBloc>().add(UpdateEntry(updated));
    Navigator.of(context).pop();
  }

  Widget _buildImagePreview() {
    if (_attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _attachments.length,
            itemBuilder: (ctx, i) {
              final a = _attachments[i];
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => OpenFile.open(a.url),
                      child: Image.file(
                        File(a.url),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(i),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Image'),
              ),
            ),
            _buildImagePreview(),
            PrimaryButton(label: 'Save Changes', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
