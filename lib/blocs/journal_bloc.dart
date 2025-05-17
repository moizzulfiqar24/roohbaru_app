// lib/blocs/journal_bloc.dart

import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';
import '../services/ai_service.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService = AIService();

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
          // If any attachment carries Base64 data, decode and write it locally
          final List<Attachment> rehydrated = [];
          for (var att in entry.attachments) {
            if (att.base64Data != null) {
              // Decode Base64
              final bytes = base64Decode(att.base64Data!);
              // Ensure directory exists
              final appDir = await getApplicationDocumentsDirectory();
              final imagesDir = Directory('${appDir.path}/attachments/images');
              if (!await imagesDir.exists()) {
                await imagesDir.create(recursive: true);
              }
              // Save to a file named by the original attachment name
              final filePath = path.join(imagesDir.path, att.name);
              final file = File(filePath);
              await file.writeAsBytes(bytes);
              // Build a new Attachment without Base64 data
              rehydrated.add(Attachment(
                url: filePath,
                name: att.name,
                type: att.type,
              ));
            } else {
              rehydrated.add(att);
            }
          }
          // Replace attachments on the entry
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

  Future<void> _onAddEntry(AddEntry event, Emitter<JournalState> emit) async {
    try {
      // 1) Analyze with AI
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      var enriched = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: [aiResult.song, aiResult.movie],
      );

      // 2) Embed each image as Base64 under the 'data' key
      enriched = await _prepareEntryForFirestore(enriched);

      // 3) Write to Firestore
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

      // Only re-run AI if content changed
      if (event.entry.content.trim() != previous.content.trim()) {
        final aiResult = await _aiService.analyzeEntry(event.entry.content);
        updatedEntry = event.entry.copyWith(
          sentiment: aiResult.sentiment,
          mood: aiResult.mood,
          suggestions: [aiResult.song, aiResult.movie],
        );
      } else {
        updatedEntry = event.entry;
      }

      // Embed Base64 data for any new images
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

  /// Reads each image file, converts to Base64 (if not already), enforces size limit,
  /// and returns a new JournalEntry whose attachments carry that Base64 in 'data'.
  Future<JournalEntry> _prepareEntryForFirestore(JournalEntry entry) async {
    final processed = <Attachment>[];
    for (var a in entry.attachments) {
      if (a.type == 'image' && a.base64Data == null) {
        final bytes = await File(a.url).readAsBytes();
        final b64 = base64Encode(bytes);
        if (b64.length > _maxFirestoreBase64Size) {
          throw Exception(
            'Image "${a.name}" is too large to store in Firestore (<1 MB Base64).',
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
