import 'package:equatable/equatable.dart';
import '../../models/journal_entry.dart';

/// Base class for all JournalBloc events
abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading entries for a given user
class LoadEntries extends JournalEvent {
  final String userId;
  const LoadEntries(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Add a new journal entry
class AddEntry extends JournalEvent {
  final JournalEntry entry;
  const AddEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Update an existing journal entry
class UpdateEntry extends JournalEvent {
  final JournalEntry entry;
  const UpdateEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Delete a journal entry by ID
class DeleteEntry extends JournalEvent {
  final String entryId;
  const DeleteEntry(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

/// Internally dispatched when Firestore yields new data
class EntriesUpdated extends JournalEvent {
  final List<JournalEntry> entries;
  const EntriesUpdated(this.entries);

  @override
  List<Object?> get props => [entries];
}

/// Internally dispatched if Firestore subscription fails
class EntriesLoadFailed extends JournalEvent {
  final String error;
  const EntriesLoadFailed(this.error);

  @override
  List<Object?> get props => [error];
}
