import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/journal_entry.dart';
import '../../services/ai_service.dart';
import '../../services/shared_prefs_service.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService = AIService(
    calm: false,
    cheerful: false,
    empathetic: true,
    gentle: false,
    supportive: true,
    humorous: false,
    mindful: false,
    optimistic: false,
  );
  final SharedPrefsService _prefs = SharedPrefsService();

  static const int _maxFirestoreBase64Size = 1024 * 1024;
  StreamSubscription<QuerySnapshot>? _subscription;

  JournalBloc() : super(JournalInitial()) {
    on<LoadEntries>(_onLoadEntries);
    on<EntriesUpdated>(_onEntriesUpdated);
    on<EntriesLoadFailed>(_onEntriesLoadFailed);
    on<AddEntry>(_onAddEntry);
    on<UpdateEntry>(_onUpdateEntry);
    on<DeleteEntry>(_onDeleteEntry);
  }

  Future<void> _onLoadEntries(
      LoadEntries event, Emitter<JournalState> emit) async {
    final uid = event.userId;

    // 1) Show loading then cached month‐entries if available
    emit(JournalLoading());
    final cached = await _prefs.loadCachedEntriesForMonth(uid);
    if (cached.isNotEmpty) {
      // show cached month entries until live data arrives
      emit(JournalLoaded(cached));
    }

    // 2) Cancel any prior Firestore listener
    await _subscription?.cancel();

    // 3) Start new Firestore subscription
    _subscription = _firestore
        .collection('entries')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) async {
      final all = <JournalEntry>[];

      // Decode and rehydrate attachments
      for (var doc in snap.docs) {
        var entry = JournalEntry.fromFirestore(doc);
        final rehydrated = <Attachment>[];
        for (var att in entry.attachments) {
          if (att.base64Data != null) {
            final bytes = base64Decode(att.base64Data!);
            final dir = await getApplicationDocumentsDirectory();
            final imagesDir = Directory('${dir.path}/attachments/images');
            if (!await imagesDir.exists()) {
              await imagesDir.create(recursive: true);
            }
            final filePath = path.join(imagesDir.path, att.name);
            await File(filePath).writeAsBytes(bytes);
            rehydrated.add(
              Attachment(url: filePath, name: att.name, type: att.type),
            );
          } else {
            rehydrated.add(att);
          }
        }
        entry = entry.copyWith(attachments: rehydrated);
        all.add(entry);
      }

      // Filter only current‐month entries for caching
      final now = DateTime.now();
      final monthEntries = all
          .where((e) =>
              e.timestamp.year == now.year && e.timestamp.month == now.month)
          .toList();

      // Cache current‐month entries
      await _prefs.cacheEntriesForMonth(uid, monthEntries);

      // Tell the bloc to emit *all* entries
      add(EntriesUpdated(all));
    }, onError: (err) {
      add(EntriesLoadFailed(err.toString()));
    });
  }

  void _onEntriesUpdated(EntriesUpdated event, Emitter<JournalState> emit) {
    // Emit the full list to UI
    emit(JournalLoaded(event.entries));
  }

  void _onEntriesLoadFailed(
      EntriesLoadFailed event, Emitter<JournalState> emit) {
    emit(JournalError('Failed to load entries: ${event.error}'));
  }

  Future<void> _onAddEntry(AddEntry event, Emitter<JournalState> emit) async {
    try {
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      var enriched = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: aiResult.suggestions,
        analysis: aiResult.analysis,
      );
      enriched = await _prepareEntryForFirestore(enriched);
      await _firestore
          .collection('entries')
          .doc(enriched.id)
          .set(enriched.toMap());
    } catch (e, st) {
      log('AddEntry error: $e\n$st');
      emit(JournalError('Failed to add entry: $e'));
    }
  }

  Future<void> _onUpdateEntry(
      UpdateEntry event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      final docRef = _firestore.collection('entries').doc(event.entry.id);
      final existing = await docRef.get();
      if (!existing.exists) {
        emit(JournalError('Entry not found for update.'));
        return;
      }

      final prev = JournalEntry.fromFirestore(existing);
      JournalEntry updated = event.entry;
      if (event.entry.content.trim() != prev.content.trim()) {
        final aiResult = await _aiService.analyzeEntry(event.entry.content);
        updated = event.entry.copyWith(
          sentiment: aiResult.sentiment,
          mood: aiResult.mood,
          suggestions: aiResult.suggestions,
          analysis: aiResult.analysis,
        );
      }

      updated = await _prepareEntryForFirestore(updated);
      await docRef.update(updated.toMap());
    } catch (e, st) {
      log('UpdateEntry error: $e\n$st');
      emit(JournalError('Failed to update entry: $e'));
    }
  }

  Future<void> _onDeleteEntry(
      DeleteEntry event, Emitter<JournalState> emit) async {
    try {
      await _firestore.collection('entries').doc(event.entryId).delete();
    } catch (e, st) {
      log('DeleteEntry error: $e\n$st');
      emit(JournalError('Failed to delete entry: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  /// Compress + Base64‐encode attachments before saving to Firestore
  Future<JournalEntry> _prepareEntryForFirestore(JournalEntry entry) async {
    final processed = <Attachment>[];
    for (var a in entry.attachments) {
      if (a.type == 'image' && a.base64Data == null) {
        Uint8List bytes = await File(a.url).readAsBytes();
        final estimate = (bytes.length * 4 / 3).ceil();
        if (estimate > _maxFirestoreBase64Size) {
          Uint8List? compressed;
          try {
            compressed =
                await FlutterImageCompress.compressWithFile(a.url, quality: 70);
          } catch (_) {
            compressed = null;
          }
          if (compressed != null && compressed.lengthInBytes < bytes.length) {
            bytes = compressed;
          } else {
            final orig = img.decodeImage(bytes);
            if (orig != null) {
              final resized = img.copyResize(orig, width: 800);
              bytes = Uint8List.fromList(
                img.encodeJpg(resized, quality: 70),
              );
            }
          }
        }
        final b64 = base64Encode(bytes);
        if (b64.length > _maxFirestoreBase64Size) {
          throw Exception(
              'Image "${a.name}" is too large even after compression.');
        }
        processed.add(Attachment(
          url: a.url,
          name: a.name,
          type: a.type,
          base64Data: b64,
        ));
      } else {
        processed.add(a);
      }
    }
    return entry.copyWith(attachments: processed);
  }
}
