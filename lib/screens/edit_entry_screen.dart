import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roohbaru_app/widgets/navbar_new_entry.dart';
import 'package:open_file/open_file.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../blocs/Journal/journal_bloc.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';
import '../blocs/EditEntry/edit_entry_bloc.dart';
import '../blocs/EditEntry/edit_entry_event.dart';
import '../blocs/EditEntry/edit_entry_state.dart';

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

  void _toggleEditing(BuildContext blocCtx) =>
      blocCtx.read<EditEntryBloc>().add(const ToggleEditing());

  void _toggleMic(BuildContext blocCtx) =>
      blocCtx.read<EditEntryBloc>().add(const ToggleMic());

  Future<void> _pickImages(BuildContext blocCtx) async {
    try {
      final List<XFile>? picked =
          await _picker.pickMultiImage(imageQuality: 80);
      if (picked == null) return;

      for (var xfile in picked) {
        final saved = await _fileService.saveImageLocally(File(xfile.path));
        blocCtx.read<EditEntryBloc>().add(
              AddEntryAttachment(
                Attachment(
                  url: saved.path,
                  name: xfile.name,
                  type: 'image',
                ),
              ),
            );
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(BuildContext blocCtx, int index) =>
      blocCtx.read<EditEntryBloc>().add(RemoveEntryAttachment(index));

  void _submit(BuildContext blocCtx) {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    blocCtx.read<EditEntryBloc>().add(
          SubmitEditEntry(title: title, content: content),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditEntryBloc>(
      create: (ctx) => EditEntryBloc(
        ctx.read<JournalBloc>(),
        widget.entry,
      ),
      child: BlocListener<EditEntryBloc, EditEntryState>(
        listener: (blocCtx, state) {
          if (state.status == EditEntryStatus.success) {
            Navigator.of(blocCtx).pop();
          }
        },
        child: BlocBuilder<EditEntryBloc, EditEntryState>(
          builder: (blocCtx, state) {
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(blocCtx).pop(),
                                child: const Icon(
                                  PhosphorIcons.arrowCircleLeft,
                                  size: 32,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _submit(blocCtx),
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
                            readOnly: !state.isEditing,
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
                              errorText: state.showTitleError
                                  ? 'Title is required'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextField(
                              controller: _contentCtrl,
                              readOnly: !state.isEditing,
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
                        if (state.attachments.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              scrollDirection: Axis.horizontal,
                              itemCount: state.attachments.length,
                              itemBuilder: (ctx, i) {
                                final a = state.attachments[i];
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
                                          onTap: () => _removeImage(blocCtx, i),
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
                      state.isEditing
                          ? NavbarNewEntry(
                              icon: PhosphorIcons.pencilSimple,
                              active: true,
                              onTap: () => _toggleEditing(blocCtx),
                            )
                          : NavbarNewEntry(
                              iconWidget: SvgPicture.asset(
                                'assets/icons/pencil-simple-slash.svg',
                                width: 30,
                                height: 30,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black54,
                                  BlendMode.srcIn,
                                ),
                              ),
                              active: false,
                              onTap: () => _toggleEditing(blocCtx),
                            ),
                      NavbarNewEntry(
                        icon: PhosphorIcons.image,
                        active: false,
                        onTap: () => _pickImages(blocCtx),
                      ),
                      NavbarNewEntry(
                        icon: state.isMicActive
                            ? PhosphorIcons.microphone
                            : PhosphorIcons.microphoneSlash,
                        active: state.isMicActive,
                        onTap: () => _toggleMic(blocCtx),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
