import 'package:equatable/equatable.dart';
import '../models/journal_entry.dart';

abstract class JournalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final List<JournalEntry> entries;
  JournalLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class JournalError extends JournalState {
  final String message;
  JournalError(this.message);

  @override
  List<Object?> get props => [message];
}
