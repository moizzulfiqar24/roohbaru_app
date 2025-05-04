import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  JournalBloc() : super(JournalInitial()) {
    on<LoadEntries>(_onLoadEntries);
    on<AddEntry>(_onAddEntry);
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
          .map((snapshot) => snapshot.docs
              .map((doc) => JournalEntry.fromFirestore(doc))
              .toList());

      await emit.forEach<List<JournalEntry>>(
        stream,
        onData: (entries) {
          return JournalLoaded(entries);
        },
        onError: (_, __) => JournalError('Failed to load journal entries.'),
      );
    } catch (e, st) {
      log('Error setting up stream: $e\n$st');
      emit(JournalError('Something went wrong while loading entries.'));
    }
  }

  Future<void> _onAddEntry(AddEntry event, Emitter<JournalState> emit) async {
    try {
      await _firestore.collection('entries').add(event.entry.toMap());
      log('Entry added: ${event.entry.title}');
    } catch (e, st) {
      log('Failed to add entry: $e\n$st');
      emit(JournalError('Failed to add entry.'));
    }
  }
}
