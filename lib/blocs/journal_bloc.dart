// lib/blocs/journal_bloc.dart

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
      // build a stream of List<JournalEntry> from your query
      final stream = _firestore
          .collection('entries')
          .where('userId', isEqualTo: event.userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => JournalEntry.fromFirestore(d)).toList());

      // await emit.forEach keeps the handler alive and routes every new snapshot
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
    // no emit(JournalLoading()) here—UI is already showing snapshot state
    try {
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      final enriched = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: aiResult.suggestions,
      );
      await _firestore
          .collection('entries')
          .doc(enriched.id)
          .set(enriched.toMap());
      // ❌ no local emit—your snapshot handler will fire and emit the new list
    } catch (e, st) {
      log('AddEntry error: $e\n$st');
      emit(JournalError('Failed to add entry: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEntry(
      UpdateEntry event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      final aiResult = await _aiService.analyzeEntry(event.entry.content);
      final enriched = event.entry.copyWith(
        sentiment: aiResult.sentiment,
        mood: aiResult.mood,
        suggestions: aiResult.suggestions,
      );
      await _firestore
          .collection('entries')
          .doc(enriched.id)
          .update(enriched.toMap());
      // snapshot will pick up the change and re-emit
    } catch (e, st) {
      log('UpdateEntry error: $e\n$st');
      emit(JournalError('Failed to update entry: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEntry(
      DeleteEntry event, Emitter<JournalState> emit) async {
    try {
      await _firestore.collection('entries').doc(event.entryId).delete();
      // snapshot will re-emit remaining entries
    } catch (e, st) {
      log('DeleteEntry error: $e\n$st');
      emit(JournalError('Failed to delete entry: ${e.toString()}'));
    }
  }
}
