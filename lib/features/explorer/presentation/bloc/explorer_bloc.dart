import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/file_item_entity.dart';

part 'explorer_event.dart';
part 'explorer_state.dart';

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  String _currentPath = '/';
  final List<String> _pathHistory = [];
  int _historyIndex = -1;

  ExplorerBloc() : super(const ExplorerInitial()) {
    on<ExplorerLoad>(_onLoad);
    on<ExplorerNavigateTo>(_onNavigateTo);
    on<ExplorerNavigateUp>(_onNavigateUp);
    on<ExplorerNavigateBack>(_onNavigateBack);
    on<ExplorerNavigateForward>(_onNavigateForward);
    on<ExplorerCreateFile>(_onCreateFile);
    on<ExplorerCreateDirectory>(_onCreateDirectory);
    on<ExplorerDeleteItem>(_onDeleteItem);
    on<ExplorerRenameItem>(_onRenameItem);
    on<ExplorerCopyItem>(_onCopyItem);
    on<ExplorerMoveItem>(_onMoveItem);
    on<ExplorerToggleSelection>(_onToggleSelection);
    on<ExplorerClearSelection>(_onClearSelection);
    on<ExplorerToggleShowHidden>(_onToggleShowHidden);
    on<ExplorerSort>(_onSort);
  }

  Future<void> _onLoad(
    ExplorerLoad event,
    Emitter<ExplorerState> emit,
  ) async {
    emit(const ExplorerLoading());

    try {
      final rootPath = await _getRootPath();
      _currentPath = event.initialPath ?? rootPath;
      
      final items = await _listDirectory(_currentPath);
      
      _addToHistory(_currentPath);
      
      emit(ExplorerReady(
        currentPath: _currentPath,
        items: items,
        selectedItems: const {},
        showHidden: false,
        sortBy: SortType.name,
        sortAscending: true,
        canGoBack: _historyIndex > 0,
        canGoForward: _historyIndex < _pathHistory.length - 1,
        canGoUp: _currentPath != '/' && _currentPath.isNotEmpty,
      ));
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onNavigateTo(
    ExplorerNavigateTo event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    emit(const ExplorerLoading());

    try {
      final entity = await _getFileSystemEntity(event.path);
      
      if (entity is Directory) {
        _currentPath = event.path;
        final items = await _listDirectory(_currentPath);
        _addToHistory(_currentPath);
        
        emit(ExplorerReady(
          currentPath: _currentPath,
          items: items,
          selectedItems: const {},
          showHidden: currentState.showHidden,
          sortBy: currentState.sortBy,
          sortAscending: currentState.sortAscending,
          canGoBack: _historyIndex > 0,
          canGoForward: _historyIndex < _pathHistory.length - 1,
          canGoUp: _currentPath != '/' && _currentPath.isNotEmpty,
        ));
      } else if (entity is File) {
        emit(ExplorerFileSelected(path: event.path));
        emit(currentState);
      }
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onNavigateUp(
    ExplorerNavigateUp event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    if (_currentPath == '/' || _currentPath.isEmpty) return;

    final parentPath = path.dirname(_currentPath);
    
    add(ExplorerNavigateTo(parentPath));
  }

  void _onNavigateBack(
    ExplorerNavigateBack event,
    Emitter<ExplorerState> emit,
  ) {
    if (_historyIndex <= 0) return;
    
    _historyIndex--;
    add(ExplorerNavigateTo(_pathHistory[_historyIndex]));
  }

  void _onNavigateForward(
    ExplorerNavigateForward event,
    Emitter<ExplorerState> emit,
  ) {
    if (_historyIndex >= _pathHistory.length - 1) return;
    
    _historyIndex++;
    add(ExplorerNavigateTo(_pathHistory[_historyIndex]));
  }

  Future<void> _onCreateFile(
    ExplorerCreateFile event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    try {
      final filePath = path.join(_currentPath, event.name);
      final file = File(filePath);
      
      if (!await file.exists()) {
        await file.create();
        add(const ExplorerLoad());
      } else {
        emit(ExplorerError('Arquivo já existe'));
        emit(currentState);
      }
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onCreateDirectory(
    ExplorerCreateDirectory event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    try {
      final dirPath = path.join(_currentPath, event.name);
      final dir = Directory(dirPath);
      
      if (!await dir.exists()) {
        await dir.create();
        add(const ExplorerLoad());
      } else {
        emit(ExplorerError('Diretório já existe'));
        emit(currentState);
      }
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    ExplorerDeleteItem event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;

    try {
      final entity = await _getFileSystemEntity(event.path);
      
      if (entity is Directory) {
        await entity.delete(recursive: event.recursive);
      } else if (entity is File) {
        await entity.delete();
      }
      
      add(const ExplorerLoad());
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onRenameItem(
    ExplorerRenameItem event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;

    try {
      final entity = await _getFileSystemEntity(event.oldPath);
      final newPath = path.join(path.dirname(event.oldPath), event.newName);
      
      await entity.rename(newPath);
      add(const ExplorerLoad());
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onCopyItem(
    ExplorerCopyItem event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;

    try {
      final source = File(event.sourcePath);
      final destinationDir = Directory(event.destinationPath);
      
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }
      
      final newPath = path.join(
        event.destinationPath,
        path.basename(event.sourcePath),
      );
      
      await source.copy(newPath);
      add(const ExplorerLoad());
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  Future<void> _onMoveItem(
    ExplorerMoveItem event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;

    try {
      final entity = await _getFileSystemEntity(event.sourcePath);
      final newPath = path.join(
        event.destinationPath,
        path.basename(event.sourcePath),
      );
      
      await entity.rename(newPath);
      add(const ExplorerLoad());
    } catch (e) {
      emit(ExplorerError(e.toString()));
    }
  }

  void _onToggleSelection(
    ExplorerToggleSelection event,
    Emitter<ExplorerState> emit,
  ) {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    final selectedItems = Set<String>.from(currentState.selectedItems);
    
    if (selectedItems.contains(event.path)) {
      selectedItems.remove(event.path);
    } else {
      selectedItems.add(event.path);
    }

    emit(currentState.copyWith(selectedItems: selectedItems));
  }

  void _onClearSelection(
    ExplorerClearSelection event,
    Emitter<ExplorerState> emit,
  ) {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    emit(currentState.copyWith(selectedItems: const {}));
  }

  Future<void> _onToggleShowHidden(
    ExplorerToggleShowHidden event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    final items = await _listDirectory(
      _currentPath,
      showHidden: !currentState.showHidden,
    );

    emit(currentState.copyWith(
      items: items,
      showHidden: !currentState.showHidden,
    ));
  }

  Future<void> _onSort(
    ExplorerSort event,
    Emitter<ExplorerState> emit,
  ) async {
    if (state is! ExplorerReady) return;
    final currentState = state as ExplorerReady;

    final sortBy = event.sortBy ?? currentState.sortBy;
    final sortAscending = event.sortAscending ?? !currentState.sortAscending;

    final items = await _listDirectory(
      _currentPath,
      showHidden: currentState.showHidden,
      sortBy: sortBy,
      sortAscending: sortAscending,
    );

    emit(currentState.copyWith(
      items: items,
      sortBy: sortBy,
      sortAscending: sortAscending,
    ));
  }

  void _addToHistory(String path) {
    if (_historyIndex < _pathHistory.length - 1) {
      _pathHistory.removeRange(_historyIndex + 1, _pathHistory.length);
    }
    
    if (_pathHistory.isEmpty || _pathHistory.last != path) {
      _pathHistory.add(path);
      _historyIndex = _pathHistory.length - 1;
    }
  }

  Future<String> _getRootPath() async {
    try {
      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs != null && externalDirs.isNotEmpty) {
          final segments = externalDirs.first.path.split('/');
          final androidIndex = segments.indexOf('Android');
          if (androidIndex > 0) {
            return segments.sublist(0, androidIndex + 1).join('/');
          }
        }
      }
      
      final appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    } catch (e) {
      return '/';
    }
  }

  Future<FileSystemEntity> _getFileSystemEntity(String path) async {
    final file = File(path);
    if (await file.exists()) return file;
    
    final dir = Directory(path);
    if (await dir.exists()) return dir;
    
    throw Exception('Caminho não existe: $path');
  }

  Future<List<FileItemEntity>> _listDirectory(
    String dirPath, {
    bool showHidden = false,
    SortType sortBy = SortType.name,
    bool sortAscending = true,
  }) async {
    final items = <FileItemEntity>[];

    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return [];

      await for (final entity in dir.list()) {
        final name = path.basename(entity.path);
        
        if (!showHidden && name.startsWith('.')) continue;

        FileType type;
        if (entity is Directory) {
          type = FileType.directory;
        } else if (entity is File) {
          type = _getFileType(name);
        } else {
          type = FileType.unknown;
        }

        try {
          final stat = await entity.stat();
          
          items.add(FileItemEntity(
            path: entity.path,
            name: name,
            type: type,
            size: stat.size,
            modifiedAt: stat.modified,
            isHidden: name.startsWith('.'),
          ));
        } catch (e) {
          // Ignorar itens que não podem ser acessados
        }
      }

      _sortItems(items, sortBy, sortAscending);
    } catch (e) {
      // Ignorar erros de permissão
    }

    return items;
  }

  void _sortItems(
    List<FileItemEntity> items,
    SortType sortBy,
    bool sortAscending,
  ) {
    items.sort((a, b) {
      if (a.type == FileType.directory && b.type != FileType.directory) {
        return -1;
      }
      if (a.type != FileType.directory && b.type == FileType.directory) {
        return 1;
      }

      int compareResult;
      
      switch (sortBy) {
        case SortType.name:
          compareResult = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortType.size:
          compareResult = a.size.compareTo(b.size);
          break;
        case SortType.date:
          compareResult = a.modifiedAt.compareTo(b.modifiedAt);
          break;
        case SortType.type:
          compareResult = a.type.index.compareTo(b.type.index);
          break;
      }

      return sortAscending ? compareResult : -compareResult;
    });
  }

  FileType _getFileType(String name) {
    final ext = path.extension(name).toLowerCase();
    
    const imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.bmp', '.ico'};
    const videoExtensions = {'.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm'};
    const audioExtensions = {'.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a'};
    const documentExtensions = {'.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt'};
    const archiveExtensions = {'.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'};
    const codeExtensions = {
      '.dart', '.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.kt', '.go', '.rs',
      '.c', '.cpp', '.h', '.hpp', '.html', '.css', '.scss', '.json', '.yaml', '.yml',
      '.xml', '.md', '.sql', '.sh', '.bat', '.ps1', '.php', '.rb', '.swift',
    };

    if (imageExtensions.contains(ext)) return FileType.image;
    if (videoExtensions.contains(ext)) return FileType.video;
    if (audioExtensions.contains(ext)) return FileType.audio;
    if (documentExtensions.contains(ext)) return FileType.document;
    if (archiveExtensions.contains(ext)) return FileType.archive;
    if (codeExtensions.contains(ext)) return FileType.code;
    
    return FileType.file;
  }
}
