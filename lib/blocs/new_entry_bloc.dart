// lib/blocs/new_entry_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import 'journal_bloc.dart';
import 'journal_event.dart';
import 'new_entry_event.dart';
import 'new_entry_state.dart';

class NewEntryBloc extends Bloc<NewEntryEvent, NewEntryState> {
  final JournalBloc journalBloc;
  final String userId;

  NewEntryBloc(this.journalBloc, this.userId) : super(const NewEntryState()) {
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
    on<SubmitEntry>((e, emit) {
      if (e.title.isEmpty) {
        emit(state.copyWith(showTitleError: true));
      } else {
        final entry = JournalEntry(
          id: const Uuid().v4(),
          userId: userId,
          title: e.title,
          content: e.content,
          timestamp: DateTime.now(),
          attachments: state.attachments,
        );
        journalBloc.add(AddEntry(entry));
        emit(state.copyWith(status: NewEntryStatus.success, entry: entry));
      }
    });
  }
}
