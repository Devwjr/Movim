part of 'explorer_bloc.dart';

abstract class ExplorerState extends Equatable {
  const ExplorerState();

  @override
  List<Object?> get props => [];
}

class ExplorerInitial extends ExplorerState {
  const ExplorerInitial();
}

class ExplorerLoading extends ExplorerState {
  const ExplorerLoading();
}

class ExplorerReady extends ExplorerState {
  final String currentPath;
  final List<FileItemEntity> items;
  final Set<String> selectedItems;
  final bool showHidden;
  final SortType sortBy;
  final bool sortAscending;
  final bool canGoBack;
  final bool canGoForward;
  final bool canGoUp;

  const ExplorerReady({
    required this.currentPath,
    required this.items,
    this.selectedItems = const {},
    this.showHidden = false,
    this.sortBy = SortType.name,
    this.sortAscending = true,
    this.canGoBack = false,
    this.canGoForward = false,
    this.canGoUp = false,
  });

  @override
  List<Object?> get props => [
        currentPath,
        items,
        selectedItems,
        showHidden,
        sortBy,
        sortAscending,
        canGoBack,
        canGoForward,
        canGoUp,
      ];

  ExplorerReady copyWith({
    String? currentPath,
    List<FileItemEntity>? items,
    Set<String>? selectedItems,
    bool? showHidden,
    SortType? sortBy,
    bool? sortAscending,
    bool? canGoBack,
    bool? canGoForward,
    bool? canGoUp,
  }) {
    return ExplorerReady(
      currentPath: currentPath ?? this.currentPath,
      items: items ?? this.items,
      selectedItems: selectedItems ?? this.selectedItems,
      showHidden: showHidden ?? this.showHidden,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      canGoUp: canGoUp ?? this.canGoUp,
    );
  }
}

class ExplorerError extends ExplorerState {
  final String message;

  const ExplorerError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExplorerFileSelected extends ExplorerState {
  final String path;

  const ExplorerFileSelected({required this.path});

  @override
  List<Object?> get props => [path];
}
