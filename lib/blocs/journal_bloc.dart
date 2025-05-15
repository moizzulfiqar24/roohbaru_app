import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_entry.dart';
import '../services/ai_service.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService = AIService();

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
      final stream = _firestore
          .collection('entries')
          .where('userId', isEqualTo: event.userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) =>
              snap.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList());

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
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      final enrichedEntry = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: [aiResult.song, aiResult.movie],
      );

      await _firestore
          .collection('entries')
          .doc(enrichedEntry.id)
          .set(enrichedEntry.toMap());
    } catch (e, st) {
      log('AddEntry error: $e\n$st');
      emit(JournalError('Failed to add entry: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEntry(
      UpdateEntry event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      final existingDoc =
          await _firestore.collection('entries').doc(event.entry.id).get();

      if (!existingDoc.exists) {
        emit(JournalError('Entry not found for update.'));
        return;
      }

      final previous = JournalEntry.fromFirestore(existingDoc);

      // Only call AI if content changed
      JournalEntry updatedEntry;
      if (event.entry.content.trim() != previous.content.trim()) {
        final aiResult = await _aiService.analyzeEntry(event.entry.content);
        updatedEntry = event.entry.copyWith(
          sentiment: aiResult.sentiment,
          mood: aiResult.mood,
          suggestions: [aiResult.song, aiResult.movie],
        );
      } else {
        // Just a local edit (e.g., user changed mood or attachments)
        updatedEntry = event.entry;
      }

      await _firestore
          .collection('entries')
          .doc(updatedEntry.id)
          .update(updatedEntry.toMap());
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
}
