// lib/blocs/new_entry_event.dart

import '../../models/journal_entry.dart';

abstract class NewEntryEvent {
  const NewEntryEvent();
}

class ToggleEditing extends NewEntryEvent {
  const ToggleEditing();
}

class ToggleMic extends NewEntryEvent {
  const ToggleMic();
}

class AddEntryAttachment extends NewEntryEvent {
  final Attachment attachment;
  const AddEntryAttachment(this.attachment);
}

class RemoveEntryAttachment extends NewEntryEvent {
  final int index;
  const RemoveEntryAttachment(this.index);
}

class SubmitEntry extends NewEntryEvent {
  final String title;
  final String content;
  const SubmitEntry({required this.title, required this.content});
}
