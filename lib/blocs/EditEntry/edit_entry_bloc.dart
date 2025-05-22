import 'package:flutter_bloc/flutter_bloc.dart';
import '../Journal/journal_bloc.dart';
import '../Journal/journal_event.dart';
import '../../models/journal_entry.dart';
import 'edit_entry_event.dart';
import 'edit_entry_state.dart';

class EditEntryBloc extends Bloc<EditEntryEvent, EditEntryState> {
  final JournalBloc _journalBloc;
  final JournalEntry _original;

  EditEntryBloc(this._journalBloc, this._original)
      : super(EditEntryState.initial(_original.attachments)) {
    on<ToggleEditing>((e, emit) {
      emit(state.copyWith(isEditing: !state.isEditing));
    });

    on<ToggleMic>((e, emit) {
      emit(state.copyWith(isMicActive: !state.isMicActive));
    });

    on<AddEntryAttachment>((e, emit) {
      final updated = List<Attachment>.from(state.attachments)
        ..add(e.attachment);
      emit(state.copyWith(attachments: updated));
    });

    on<RemoveEntryAttachment>((e, emit) {
      final updated = List<Attachment>.from(state.attachments)
        ..removeAt(e.index);
      emit(state.copyWith(attachments: updated));
    });

    on<SubmitEditEntry>((e, emit) {
      if (e.title.isEmpty) {
        emit(state.copyWith(showTitleError: true));
        return;
      }

      final updatedEntry = _original.copyWith(
        title: e.title,
        content: e.content,
        attachments: state.attachments,
      );

      _journalBloc.add(UpdateEntry(updatedEntry));
      emit(state.copyWith(status: EditEntryStatus.success));
    });
  }
}
