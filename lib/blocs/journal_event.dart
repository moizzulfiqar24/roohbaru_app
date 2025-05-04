import 'package:equatable/equatable.dart';
import '../models/journal_entry.dart';

abstract class JournalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEntries extends JournalEvent {
  final String userId;
  LoadEntries(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddEntry extends JournalEvent {
  final JournalEntry entry;
  AddEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class UpdateEntry extends JournalEvent {
  final JournalEntry entry;
  UpdateEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class DeleteEntry extends JournalEvent {
  final String entryId;
  DeleteEntry(this.entryId);
  @override
  List<Object?> get props => [entryId];
}
