import '../../models/journal_entry.dart';

enum EditEntryStatus { initial, success }

class EditEntryState {
  final List<Attachment> attachments;
  final bool isEditing;
  final bool isMicActive;
  final bool showTitleError;
  final EditEntryStatus status;

  const EditEntryState({
    required this.attachments,
    required this.isEditing,
    required this.isMicActive,
    required this.showTitleError,
    required this.status,
  });

  factory EditEntryState.initial(List<Attachment> initialAttachments) {
    return EditEntryState(
      attachments: List.from(initialAttachments),
      isEditing: false,
      isMicActive: false,
      showTitleError: false,
      status: EditEntryStatus.initial,
    );
  }

  EditEntryState copyWith({
    List<Attachment>? attachments,
    bool? isEditing,
    bool? isMicActive,
    bool? showTitleError,
    EditEntryStatus? status,
  }) {
    return EditEntryState(
      attachments: attachments ?? this.attachments,
      isEditing: isEditing ?? this.isEditing,
      isMicActive: isMicActive ?? this.isMicActive,
      showTitleError: showTitleError ?? this.showTitleError,
      status: status ?? this.status,
    );
  }
}
