import '../models/journal_entry.dart';

abstract class EditEntryEvent {
  const EditEntryEvent();
}

class ToggleEditing extends EditEntryEvent {
  const ToggleEditing();
}

class ToggleMic extends EditEntryEvent {
  const ToggleMic();
}

class AddEntryAttachment extends EditEntryEvent {
  final Attachment attachment;
  const AddEntryAttachment(this.attachment);
}

class RemoveEntryAttachment extends EditEntryEvent {
  final int index;
  const RemoveEntryAttachment(this.index);
}

class SubmitEditEntry extends EditEntryEvent {
  final String title;
  final String content;
  const SubmitEditEntry({required this.title, required this.content});
}
