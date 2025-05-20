// lib/blocs/journal_bloc.dart

import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';
import '../services/ai_service.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Pass in your desired personalities here:
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

  /// Firestore only allows <1 MB per string field.
  static const int _maxFirestoreBase64Size = 1024 * 1024;

  JournalBloc() : super(JournalInitial()) {
    on<LoadEntries>(_onLoadEntries);
    on<AddEntry>(_onAddEntry);
    on<UpdateEntry>(_onUpdateEntry);
    on<DeleteEntry>(_onDeleteEntry);
  }

  Future<void> _onLoadEntries(
      LoadEntries event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      // Listen to snapshots, then for each batch decode+rehydrate any Base64 images
      final stream = _firestore
          .collection('entries')
          .where('userId', isEqualTo: event.userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .asyncMap((snap) async {
        final List<JournalEntry> entries = [];
        for (var doc in snap.docs) {
          var entry = JournalEntry.fromFirestore(doc);
          final List<Attachment> rehydrated = [];
          for (var att in entry.attachments) {
            if (att.base64Data != null) {
              final bytes = base64Decode(att.base64Data!);
              final appDir = await getApplicationDocumentsDirectory();
              final imagesDir = Directory('${appDir.path}/attachments/images');
              if (!await imagesDir.exists()) {
                await imagesDir.create(recursive: true);
              }
              final filePath = path.join(imagesDir.path, att.name);
              final file = File(filePath);
              await file.writeAsBytes(bytes);
              rehydrated.add(Attachment(
                url: filePath,
                name: att.name,
                type: att.type,
              ));
            } else {
              rehydrated.add(att);
            }
          }
          entry = entry.copyWith(attachments: rehydrated);
          entries.add(entry);
        }
        return entries;
      });

      await emit.forEach<List<JournalEntry>>(
        stream,
        onData: (entries) => JournalLoaded(entries),
        onError: (_, __) => JournalError('Failed to load journal entries.'),
      );
    } catch (e, st) {
      log('LoadEntries error: $e\n$st');
      emit(JournalError('Something went wrong: $e'));
    }
  }

  // Future<void> _onAddEntry(AddEntry event, Emitter<JournalState> emit) async {
  //   try {
  //     final aiResult = await _aiService.analyzeEntry(event.entry.content);
  //     var enriched = event.entry.copyWith(
  //       sentiment: aiResult.sentiment,
  //       mood: aiResult.mood,
  //       suggestions: [aiResult.song, aiResult.movie],
  //     );
  //     enriched = await _prepareEntryForFirestore(enriched);
  //     await _firestore
  //         .collection('entries')
  //         .doc(enriched.id)
  //         .set(enriched.toMap());
  //   } catch (e, st) {
  //     log('AddEntry error: $e\n$st');
  //     emit(JournalError('Failed to add entry: ${e.toString()}'));
  //   }
  // }

  // Future<void> _onUpdateEntry(
  //     UpdateEntry event, Emitter<JournalState> emit) async {
  //   emit(JournalLoading());
  //   try {
  //     final docRef = _firestore.collection('entries').doc(event.entry.id);
  //     final existingDoc = await docRef.get();
  //     if (!existingDoc.exists) {
  //       emit(JournalError('Entry not found for update.'));
  //       return;
  //     }

  //     final previous = JournalEntry.fromFirestore(existingDoc);
  //     JournalEntry updatedEntry;

  //     if (event.entry.content.trim() != previous.content.trim()) {
  //       final aiResult = await _aiService.analyzeEntry(event.entry.content);
  //       updatedEntry = event.entry.copyWith(
  //         sentiment: aiResult.sentiment,
  //         mood: aiResult.mood,
  //         suggestions: [aiResult.song, aiResult.movie],
  //       );
  //     } else {
  //       updatedEntry = event.entry;
  //     }

  //     updatedEntry = await _prepareEntryForFirestore(updatedEntry);
  //     await docRef.update(updatedEntry.toMap());
  //   } catch (e, st) {
  //     log('UpdateEntry error: $e\n$st');
  //     emit(JournalError('Failed to update entry: ${e.toString()}'));
  //   }
  // }

  Future<void> _onAddEntry(AddEntry event, Emitter<JournalState> emit) async {
    try {
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      var enriched = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: aiResult.suggestions,
        analysis: aiResult.analysis, // ← store analysis
      );
      enriched = await _prepareEntryForFirestore(enriched);
      await _firestore
          .collection('entries')
          .doc(enriched.id)
          .set(enriched.toMap());
    } catch (e, st) {
      log('AddEntry error: $e\n$st');
      emit(JournalError('Failed to add entry: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEntry(
      UpdateEntry event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      final docRef = _firestore.collection('entries').doc(event.entry.id);
      final existingDoc = await docRef.get();
      if (!existingDoc.exists) {
        emit(JournalError('Entry not found for update.'));
        return;
      }

      final previous = JournalEntry.fromFirestore(existingDoc);
      JournalEntry updatedEntry;

      if (event.entry.content.trim() != previous.content.trim()) {
        final aiResult = await _aiService.analyzeEntry(event.entry.content);
        updatedEntry = event.entry.copyWith(
          sentiment: aiResult.sentiment,
          mood: aiResult.mood,
          suggestions: aiResult.suggestions,
          analysis: aiResult.analysis, // ← update analysis
        );
      } else {
        updatedEntry = event.entry;
      }

      updatedEntry = await _prepareEntryForFirestore(updatedEntry);
      await docRef.update(updatedEntry.toMap());
    } catch (e, st) {
      log('UpdateEntry error: $e\n$st');
      emit(JournalError('Failed to update entry: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEntry(
      DeleteEntry event, Emitter<JournalState> emit) async {
    try {
      await _firestore.collection('entries').doc(event.entryId).delete();
    } catch (e, st) {
      log('DeleteEntry error: $e\n$st');
      emit(JournalError('Failed to delete entry: ${e.toString()}'));
    }
  }

  /// Reads each image file, compresses (plugin then Dart fallback), encodes to Base64,
  /// enforces size limit, and returns a new JournalEntry whose attachments carry that Base64.
  Future<JournalEntry> _prepareEntryForFirestore(JournalEntry entry) async {
    final processed = <Attachment>[];

    for (var a in entry.attachments) {
      if (a.type == 'image' && a.base64Data == null) {
        // Read original bytes
        Uint8List bytes = await File(a.url).readAsBytes();

        // Estimate Base64 size
        final estimatedSize = (bytes.length * 4 / 3).ceil();
        if (estimatedSize > _maxFirestoreBase64Size) {
          // 1) Try native plugin compression
          Uint8List? compressed;
          try {
            compressed = await FlutterImageCompress.compressWithFile(
              a.url,
              quality: 70,
            );
          } catch (_) {
            compressed = null;
          }

          if (compressed != null && compressed.lengthInBytes < bytes.length) {
            bytes = compressed;
          } else {
            // 2) Dart fallback using 'image' package
            final img.Image? original = img.decodeImage(bytes);
            if (original != null) {
              final img.Image resized = img.copyResize(original, width: 800);
              final List<int> jpg = img.encodeJpg(resized, quality: 70);
              bytes = Uint8List.fromList(jpg);
            }
          }
        }

        final b64 = base64Encode(bytes);
        if (b64.length > _maxFirestoreBase64Size) {
          throw Exception(
            'Image "${a.name}" is too large even after compression (<1 MB Base64).',
          );
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
