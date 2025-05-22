// lib/blocs/new_entry_state.dart

import '../../models/journal_entry.dart';

enum NewEntryStatus { initial, error, success }

class NewEntryState {
  final bool isEditing;
  final bool isMicActive;
  final bool showTitleError;
  final List<Attachment> attachments;
  final NewEntryStatus status;
  final JournalEntry? entry;

  const NewEntryState({
    this.isEditing = false,
    this.isMicActive = false,
    this.showTitleError = false,
    this.attachments = const [],
    this.status = NewEntryStatus.initial,
    this.entry,
  });

  NewEntryState copyWith({
    bool? isEditing,
    bool? isMicActive,
    bool? showTitleError,
    List<Attachment>? attachments,
    NewEntryStatus? status,
    JournalEntry? entry,
  }) {
    return NewEntryState(
      isEditing: isEditing ?? this.isEditing,
      isMicActive: isMicActive ?? this.isMicActive,
      showTitleError: showTitleError ?? this.showTitleError,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      entry: entry ?? this.entry,
    );
  }
}
