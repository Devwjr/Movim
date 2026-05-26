part of 'explorer_bloc.dart';

abstract class ExplorerEvent extends Equatable {
  const ExplorerEvent();

  @override
  List<Object?> get props => [];
}

class ExplorerLoad extends ExplorerEvent {
  final String? initialPath;

  const ExplorerLoad({this.initialPath});

  @override
  List<Object?> get props => [initialPath];
}

class ExplorerNavigateTo extends ExplorerEvent {
  final String path;

  const ExplorerNavigateTo(this.path);

  @override
  List<Object?> get props => [path];
}

class ExplorerNavigateUp extends ExplorerEvent {
  const ExplorerNavigateUp();
}

class ExplorerNavigateBack extends ExplorerEvent {
  const ExplorerNavigateBack();
}

class ExplorerNavigateForward extends ExplorerEvent {
  const ExplorerNavigateForward();
}

class ExplorerCreateFile extends ExplorerEvent {
  final String name;

  const ExplorerCreateFile(this.name);

  @override
  List<Object?> get props => [name];
}

class ExplorerCreateDirectory extends ExplorerEvent {
  final String name;

  const ExplorerCreateDirectory(this.name);

  @override
  List<Object?> get props => [name];
}

class ExplorerDeleteItem extends ExplorerEvent {
  final String path;
  final bool recursive;

  const ExplorerDeleteItem(this.path, {this.recursive = false});

  @override
  List<Object?> get props => [path, recursive];
}

class ExplorerRenameItem extends ExplorerEvent {
  final String oldPath;
  final String newName;

  const ExplorerRenameItem({
    required this.oldPath,
    required this.newName,
  });

  @override
  List<Object?> get props => [oldPath, newName];
}

class ExplorerCopyItem extends ExplorerEvent {
  final String sourcePath;
  final String destinationPath;

  const ExplorerCopyItem({
    required this.sourcePath,
    required this.destinationPath,
  });

  @override
  List<Object?> get props => [sourcePath, destinationPath];
}

class ExplorerMoveItem extends ExplorerEvent {
  final String sourcePath;
  final String destinationPath;

  const ExplorerMoveItem({
    required this.sourcePath,
    required this.destinationPath,
  });

  @override
  List<Object?> get props => [sourcePath, destinationPath];
}

class ExplorerToggleSelection extends ExplorerEvent {
  final String path;

  const ExplorerToggleSelection(this.path);

  @override
  List<Object?> get props => [path];
}

class ExplorerClearSelection extends ExplorerEvent {
  const ExplorerClearSelection();
}

class ExplorerToggleShowHidden extends ExplorerEvent {
  const ExplorerToggleShowHidden();
}

class ExplorerSort extends ExplorerEvent {
  final SortType? sortBy;
  final bool? sortAscending;

  const ExplorerSort({
    this.sortBy,
    this.sortAscending,
  });

  @override
  List<Object?> get props => [sortBy, sortAscending];
}
