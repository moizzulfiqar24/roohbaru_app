// lib/screens/new_entry_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roohbaru_app/widgets/navbar_new_entry.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // ✅ Phosphor icons
import 'package:flutter_svg/flutter_svg.dart'; // ✅ For SVG support
import 'package:speech_to_text/speech_to_text.dart' as stt; // ✅ Speech-to-text

import '../blocs/Journal/journal_bloc.dart';
import '../models/journal_entry.dart';
import '../services/file_storage_service.dart';
import 'entry_detail_screen.dart';

// BLoC imports
import '../blocs/NewEntry/new_entry_bloc.dart';
import '../blocs/NewEntry/new_entry_event.dart';
import '../blocs/NewEntry/new_entry_state.dart';

class NewEntryScreen extends StatefulWidget {
  final String userId;
  const NewEntryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  // Text controllers & focus nodes
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  // File picker & storage
  final FileStorageService _fileService = FileStorageService();
  final ImagePicker _picker = ImagePicker();

  // Speech-to-text
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint('STT status: $status'),
      onError: (err) => debugPrint('STT error: $err'),
    );
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
      localeId: 'en_US',
      onResult: (result) {
        final text = result.recognizedWords;
        if (_titleFocus.hasFocus) {
          _titleCtrl.text = '${_titleCtrl.text} $text';
          _titleCtrl.selection =
              TextSelection.collapsed(offset: _titleCtrl.text.length);
        } else {
          _contentCtrl.text = '${_contentCtrl.text} $text';
          _contentCtrl.selection =
              TextSelection.collapsed(offset: _contentCtrl.text.length);
        }
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
  }

  @override
  void dispose() {
    _speech.stop();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  /// Must use the [blocCtx] coming from build(), not the State's context.
  void _toggleEditing(BuildContext blocCtx) =>
      blocCtx.read<NewEntryBloc>().add(const ToggleEditing());

  void _toggleMic(BuildContext blocCtx) =>
      blocCtx.read<NewEntryBloc>().add(const ToggleMic());

  Future<void> _pickImages(BuildContext blocCtx) async {
    try {
      final List<XFile>? picked =
          await _picker.pickMultiImage(imageQuality: 80);
      if (picked == null) return;

      for (var xfile in picked) {
        final saved = await _fileService.saveImageLocally(File(xfile.path));
        blocCtx.read<NewEntryBloc>().add(
              AddEntryAttachment(
                Attachment(url: saved.path, name: xfile.name, type: 'image'),
              ),
            );
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _submitEntry(BuildContext blocCtx) {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    blocCtx
        .read<NewEntryBloc>()
        .add(SubmitEntry(title: title, content: content));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewEntryBloc>(
      create: (ctx) => NewEntryBloc(ctx.read<JournalBloc>(), widget.userId),
      child: BlocListener<NewEntryBloc, NewEntryState>(
        listener: (ctx, state) {
          // Navigate on successful submit
          if (state.status == NewEntryStatus.success && state.entry != null) {
            Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EntryDetailScreen(entryId: state.entry!.id),
              ),
            );
          }
          // Start/stop listening when mic toggles
          if (state.isMicActive) {
            _startListening();
          } else {
            _stopListening();
          }
        },
        child: BlocBuilder<NewEntryBloc, NewEntryState>(
          builder: (blocCtx, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFf8eed5),
              body: Stack(
                children: [
                  Positioned.fill(
                    child:
                        Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Top bar
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
                                onTap: () => _submitEntry(blocCtx),
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

                        // Title field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextField(
                            controller: _titleCtrl,
                            focusNode: _titleFocus,
                            readOnly: !state.isEditing,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Give it a title...',
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

                        // Content field
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextField(
                              controller: _contentCtrl,
                              focusNode: _contentFocus,
                              readOnly: !state.isEditing,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText: 'Write your thoughts...',
                                hintStyle: TextStyle(
                                  fontFamily: 'lufga-regular',
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                        // Attachments preview (unchanged)
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
                                        child: Image.file(
                                          File(a.url),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            blocCtx
                                                .read<NewEntryBloc>()
                                                .add(RemoveEntryAttachment(i));
                                          },
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

              // Bottom nav (unchanged)
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
                          ? navbarNewEntry(
                              icon: PhosphorIcons.pencilSimple,
                              active: true,
                              onTap: () => _toggleEditing(blocCtx),
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
                              onTap: () => _toggleEditing(blocCtx),
                            ),
                      navbarNewEntry(
                        icon: PhosphorIcons.image,
                        active: false,
                        onTap: () => _pickImages(blocCtx),
                      ),
                      navbarNewEntry(
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
