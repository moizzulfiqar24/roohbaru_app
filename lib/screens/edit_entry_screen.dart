// lib/screens/edit_entry_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roohbaru_app/widgets/navbar_new_entry.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // ✅ Phosphor icons
import 'package:flutter_svg/flutter_svg.dart'; // ✅ For SVG support

import '../blocs/journal_bloc.dart';
import '../blocs/journal_event.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';

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
  bool _isEditing = false;
  bool _isMicActive = false;

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

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicActive = !_isMicActive;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked =
          await _picker.pickMultiImage(imageQuality: 80);
      if (picked == null) return;

      for (var xfile in picked) {
        final saved = await _fileService.saveImageLocally(File(xfile.path));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8eed5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        // child: const Icon(
                        //   Icons.arrow_back,
                        //   size: 28,
                        //   color: Colors.black,
                        // ),
                        child: const Icon(
                          // Icons.arrow_back,
                          PhosphorIcons.arrowCircleLeft,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF473623),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _titleCtrl,
                    readOnly: !_isEditing,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Update title...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'lufga-semi-bold',
                        fontSize: 32,
                      ),
                      border: InputBorder.none,
                      errorText: _showTitleError ? 'Title is required' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _contentCtrl,
                      readOnly: !_isEditing,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Update your thoughts...',
                        hintStyle: TextStyle(
                          fontFamily: 'lufga-regular',
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (_attachments.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachments.length,
                      itemBuilder: (ctx, i) {
                        final a = _attachments[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
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
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(85, 0, 85, 45),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _isEditing
                  ? navbarNewEntry(
                      icon: PhosphorIcons.pencilSimple,
                      active: true,
                      onTap: _toggleEditing,
                    )
                  : navbarNewEntry(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/pencil-simple-slash.svg',
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                            Colors.black54, BlendMode.srcIn),
                      ),
                      active: false,
                      onTap: _toggleEditing,
                    ),
              navbarNewEntry(
                icon: PhosphorIcons.image,
                active: false,
                onTap: _pickImages,
              ),
              navbarNewEntry(
                icon: _isMicActive
                    ? PhosphorIcons.microphone
                    : PhosphorIcons.microphoneSlash,
                active: _isMicActive,
                onTap: _toggleMic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
