class ProfileState {
  final bool showInfo;

  const ProfileState({required this.showInfo});

  factory ProfileState.initial() => const ProfileState(showInfo: false);

  ProfileState copyWith({bool? showInfo}) {
    return ProfileState(
      showInfo: showInfo ?? this.showInfo,
    );
  }
}
