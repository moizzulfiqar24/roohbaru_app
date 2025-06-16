class HomeUiState {
  /// Which nav tab is selected (0=Home,1=Search,…).
  final int selectedIndex;

  /// Which date filter is active (null = no filter).
  final DateTime? selectedDate;

  const HomeUiState({
    this.selectedIndex = 0,
    this.selectedDate,
  });

  HomeUiState copyWith({
    int? selectedIndex,
    DateTime? selectedDate,

    /// Must be set true if you want to override the old date
    bool updateDate = false,
  }) {
    return HomeUiState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedDate: updateDate ? selectedDate : this.selectedDate,
    );
  }
}
