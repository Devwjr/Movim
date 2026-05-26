import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:path/path.dart' as path;
import 'editor_event.dart';
import 'editor_state.dart';
import '../../domain/entities/buffer_entity.dart';
import '../../../../core/data/repositories/file_repository.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final FileRepository _fileRepository;
  final SettingsBloc _settingsBloc;
  String _pendingCount = '';
  final Map<String, CursorPosition> _marks = {};
  final List<CursorPosition> _jumpList = [];
  int _jumpIndex = -1;
  String _lastChange = '';

  EditorBloc({
    required FileRepository fileRepository,
    required SettingsBloc settingsBloc,
  })  : _fileRepository = fileRepository,
        _settingsBloc = settingsBloc,
        super(const EditorInitial()) {
    on<EditorNewBuffer>(_onNewBuffer);
    on<EditorLoadFile>(_onLoadFile);
    on<EditorSaveBuffer>(_onSaveBuffer);
    on<EditorCloseBuffer>(_onCloseBuffer);
    on<EditorSwitchBuffer>(_onSwitchBuffer);
    on<EditorInputKey>(_onInputKey);
    on<EditorMoveCursor>(_onMoveCursor);
    on<EditorMoveToLine>(_onMoveToLine);
    on<EditorInsertText>(_onInsertText);
    on<EditorDeleteBackward>(_onDeleteBackward);
    on<EditorDeleteForward>(_onDeleteForward);
    on<EditorDeleteLine>(_onDeleteLine);
    on<EditorChangeMode>(_onChangeMode);
    on<EditorUndo>(_onUndo);
    on<EditorRedo>(_onRedo);
    on<EditorYank>(_onYank);
    on<EditorPaste>(_onPaste);
    on<EditorDeleteSelection>(_onDeleteSelection);
    on<EditorCommandInput>(_onCommandInput);
    on<EditorExecuteCommand>(_onExecuteCommand);
    on<EditorCancelCommand>(_onCancelCommand);
    on<EditorSearch>(_onSearch);
    on<EditorFindNext>(_onFindNext);
    on<EditorFindPrevious>(_onFindPrevious);

    _initEditor();
  }

  void _initEditor() {
    final initialBuffer = BufferEntity(
      id: _generateId(),
      fileName: 'Untitled',
    );
    emit(EditorReady(
      buffers: [initialBuffer],
      activeBufferId: initialBuffer.id,
    ));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  BufferEntity _updateActiveBuffer(EditorReady state, BufferEntity newBuffer) {
    final buffers = state.buffers.map((b) {
      if (b.id == state.activeBufferId) {
        return newBuffer;
      }
      return b;
    }).toList();
    
    emit(state.copyWith(buffers: buffers));
    return newBuffer;
  }

  Future<void> _onNewBuffer(
    EditorNewBuffer event,
    Emitter<EditorState> emit,
  ) async {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;

    final newBuffer = BufferEntity(
      id: _generateId(),
      fileName: event.fileName ?? 'Untitled ${currentState.buffers.length + 1}',
    );

    emit(currentState.copyWith(
      buffers: [...currentState.buffers, newBuffer],
      activeBufferId: newBuffer.id,
    ));
  }

  Future<void> _onLoadFile(
    EditorLoadFile event,
    Emitter<EditorState> emit,
  ) async {
    emit(const EditorLoading());

    try {
      final content = await _fileRepository.readFile(event.path);
      final fileName = path.basename(event.path);
      final fileType = _getFileType(fileName);

      final existingBuffer = state is EditorReady
          ? (state as EditorReady).buffers.where((b) => b.filePath == event.path).firstOrNull
          : null;

      if (existingBuffer != null && state is EditorReady) {
        emit((state as EditorReady).copyWith(
          activeBufferId: existingBuffer.id,
        ));
        return;
      }

      final newBuffer = BufferEntity(
        id: _generateId(),
        filePath: event.path,
        fileName: fileName,
        content: content,
        fileType: fileType,
        undoStack: [content],
      );

      if (state is EditorReady) {
        final currentState = state as EditorReady;
        emit(currentState.copyWith(
          buffers: [...currentState.buffers, newBuffer],
          activeBufferId: newBuffer.id,
        ));
      } else {
        emit(EditorReady(
          buffers: [newBuffer],
          activeBufferId: newBuffer.id,
        ));
      }
    } catch (e) {
      emit(EditorError(e.toString()));
    }
  }

  Future<void> _onSaveBuffer(
    EditorSaveBuffer event,
    Emitter<EditorState> emit,
  ) async {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final savePath = event.path ?? buffer.filePath;
    if (savePath == null) {
      emit(EditorError('Nenhum caminho especificado para salvar'));
      return;
    }

    try {
      await _fileRepository.writeFile(savePath, buffer.content);

      final updatedBuffer = buffer.copyWith(
        filePath: savePath,
        fileName: path.basename(savePath),
        isModified: false,
      );

      _updateActiveBuffer(currentState, updatedBuffer);
    } catch (e) {
      emit(EditorError(e.toString()));
    }
  }

  void _onCloseBuffer(
    EditorCloseBuffer event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;

    if (currentState.buffers.length <= 1) {
      return;
    }

    final buffers = currentState.buffers.where((b) => b.id != event.bufferId).toList();
    final activeId = currentState.activeBufferId == event.bufferId
        ? buffers.first.id
        : currentState.activeBufferId;

    emit(currentState.copyWith(
      buffers: buffers,
      activeBufferId: activeId,
    ));
  }

  void _onSwitchBuffer(
    EditorSwitchBuffer event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;

    final bufferExists = currentState.buffers.any((b) => b.id == event.bufferId);
    if (bufferExists) {
      emit(currentState.copyWith(activeBufferId: event.bufferId));
    }
  }

  void _onInputKey(
    EditorInputKey event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    switch (buffer.mode) {
      case EditorMode.normal:
        _handleNormalModeKey(event, currentState, buffer);
        break;
      case EditorMode.insert:
        _handleInsertModeKey(event, currentState, buffer);
        break;
      case EditorMode.visual:
      case EditorMode.visualLine:
      case EditorMode.visualBlock:
        _handleVisualModeKey(event, currentState, buffer);
        break;
      case EditorMode.command:
        _handleCommandModeKey(event, currentState, buffer);
        break;
    }
  }

  void _handleNormalModeKey(
    EditorInputKey event,
    EditorReady state,
    BufferEntity buffer,
  ) {
    final key = event.key.toLowerCase();
    final isDigit = RegExp(r'^[0-9]$').hasMatch(key);
    final isLetter = RegExp(r'^[a-zA-Z]$').hasMatch(key);

    if (buffer.commandBuffer == 'm' && isLetter) {
      _marks[key] = buffer.cursor;
      _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
      return;
    }

    if ((buffer.commandBuffer == "'" || buffer.commandBuffer == '`') && isLetter) {
      final mark = _marks[key];
      if (mark != null) {
        _addJump(buffer);
        final newBuffer = buffer.copyWith(
          cursor: CursorPosition(line: mark.line, column: mark.column),
          commandBuffer: '',
        );
        _updateActiveBuffer(state, newBuffer);
      } else {
        _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
      }
      return;
    }

    if (event.isControl) {
      if (key == 'r') {
        add(const EditorRedo());
        return;
      }
      if (key == 'o') {
        _jumpBack(state, buffer);
        return;
      }
      if (key == 'i') {
        _jumpForward(state, buffer);
        return;
      }
      if (key == 'v') {
        add(const EditorChangeMode(EditorMode.visualBlock));
        return;
      }
      if (key == 'd') {
        add(const EditorMoveCursor(lines: 4));
        return;
      }
      if (key == 'u') {
        add(const EditorMoveCursor(lines: -4));
        return;
      }
      if (key == 'b') {
        add(const EditorMoveCursor(columns: -4));
        return;
      }
      if (key == 'f') {
        add(const EditorMoveCursor(columns: 4));
        return;
      }
      return;
    }

    if (isDigit && _pendingCount.length < 5) {
      _pendingCount += key;
      return;
    }

    final count = _pendingCount.isEmpty ? 1 : int.parse(_pendingCount);
    _pendingCount = '';

    switch (key) {
      case 'h':
        add(EditorMoveCursor(columns: -count));
        break;
      case 'j':
        add(EditorMoveCursor(lines: count));
        break;
      case 'k':
        add(EditorMoveCursor(lines: -count));
        break;
      case 'l':
        add(EditorMoveCursor(columns: count));
        break;
      case 'i':
        add(const EditorChangeMode(EditorMode.insert));
        break;
      case 'I':
        add(const EditorMoveToLine(0, column: 0));
        add(const EditorChangeMode(EditorMode.insert));
        break;
      case 'a':
        add(const EditorMoveCursor(columns: 1));
        add(const EditorChangeMode(EditorMode.insert));
        break;
      case 'A':
        add(EditorMoveToLine(
          buffer.cursor.line,
          column: buffer.currentLineLength,
        ));
        add(const EditorChangeMode(EditorMode.insert));
        break;
      case 'o':
        _openLineBelow(state, buffer);
        break;
      case 'O':
        _openLineAbove(state, buffer);
        break;
      case 'd':
        if (buffer.commandBuffer == 'd') {
          for (var i = 0; i < count; i++) {
            add(EditorDeleteLine(count: count));
          }
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
        } else {
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: 'd'));
        }
        break;
      case 'D':
        add(EditorDeleteForward(count: 9999));
        break;
      case 'y':
        if (buffer.commandBuffer == 'y') {
          add(EditorYank(isLine: true, count: count));
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
        } else {
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: 'y'));
        }
        break;
      case 'p':
        add(const EditorPaste(after: true));
        break;
      case 'P':
        add(const EditorPaste(after: false));
        break;
      case 'u':
        add(const EditorUndo());
        break;
      case 'v':
        add(const EditorChangeMode(EditorMode.visual));
        break;
      case 'V':
        add(const EditorChangeMode(EditorMode.visualLine));
        break;
      case ':':
        add(const EditorChangeMode(EditorMode.command));
        break;
      case '/':
        _startSearch(state, buffer, forward: true);
        break;
      case '?':
        _startSearch(state, buffer, forward: false);
        break;
      case 'n':
        add(const EditorFindNext());
        break;
      case 'N':
        add(const EditorFindPrevious());
        break;
      case 'x':
        for (var i = 0; i < count; i++) {
          add(const EditorDeleteForward(count: 1));
        }
        break;
      case 'X':
        for (var i = 0; i < count; i++) {
          add(const EditorDeleteBackward());
        }
        break;
      case '0':
        add(EditorMoveToLine(buffer.cursor.line, column: 0));
        break;
      case '^':
        add(EditorMoveToLine(buffer.cursor.line, column: 0));
        break;
      case r'$':
        add(EditorMoveToLine(
          buffer.cursor.line,
          column: max(0, buffer.currentLineLength - 1),
        ));
        break;
      case 'g':
        if (buffer.commandBuffer == 'g') {
          add(const EditorMoveToLine(0, column: 0));
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
        } else {
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: 'g'));
        }
        break;
      case 'G':
        add(EditorMoveToLine(buffer.lineCount - 1, column: 0));
        break;
      case 'w':
        for (var i = 0; i < count; i++) {
          _moveWordForward(state, buffer);
        }
        break;
      case 'b':
        for (var i = 0; i < count; i++) {
          _moveWordBackward(state, buffer);
        }
        break;
      case 'e':
        for (var i = 0; i < count; i++) {
          _moveWordEnd(state, buffer);
        }
        break;
      case 'W':
        for (var i = 0; i < count; i++) {
          _moveWordForward(state, buffer);
        }
        break;
      case 'B':
        for (var i = 0; i < count; i++) {
          _moveWordBackward(state, buffer);
        }
        break;
      case 'E':
        for (var i = 0; i < count; i++) {
          _moveWordEnd(state, buffer);
        }
        break;
      case 'm':
        _updateActiveBuffer(state, buffer.copyWith(commandBuffer: 'm'));
        break;
      case '\'':
        _updateActiveBuffer(state, buffer.copyWith(commandBuffer: "'"));
        break;
      case '`':
        _updateActiveBuffer(state, buffer.copyWith(commandBuffer: '`'));
        break;
      case '[':
        if (event.isShift) {
          _jumpBack(state, buffer);
        }
        break;
      case ']':
        if (event.isShift) {
          _jumpForward(state, buffer);
        }
        break;
      case 'J':
        _joinLines(state, buffer);
        break;
      case '.':
        _repeatLastChange(state, buffer);
        break;
      case '~':
        _toggleCase(state, buffer);
        break;
      case '<':
        _indentLine(state, buffer, decrease: true);
        break;
      case '>':
        _indentLine(state, buffer, decrease: false);
        break;
      default:
        if (buffer.commandBuffer.isNotEmpty) {
          _updateActiveBuffer(state, buffer.copyWith(commandBuffer: ''));
        }
    }
  }

  void _handleInsertModeKey(
    EditorInputKey event,
    EditorReady state,
    BufferEntity buffer,
  ) {
    if (event.isControl) {
      if (event.key == '[' || event.key.toLowerCase() == 'c') {
        add(const EditorMoveCursor(columns: -1));
        add(const EditorChangeMode(EditorMode.normal));
        return;
      }
      return;
    }

    if (event.key == 'Escape') {
      add(const EditorMoveCursor(columns: -1));
      add(const EditorChangeMode(EditorMode.normal));
      return;
    }

    if (event.key == 'Backspace') {
      add(const EditorDeleteBackward());
      return;
    }

    if (event.key == 'Enter') {
      _insertNewline(state, buffer);
      return;
    }

    if (event.key == 'Tab') {
      final tabChar = buffer.expandTabs ? ' ' * buffer.tabSize : '\t';
      add(EditorInsertText(tabChar));
      return;
    }

    if (event.key.length == 1) {
      add(EditorInsertText(event.key));
    }
  }

  void _handleVisualModeKey(
    EditorInputKey event,
    EditorReady state,
    BufferEntity buffer,
  ) {
    final key = event.key.toLowerCase();

    if (event.key == 'Escape' || (event.isControl && key == '[')) {
      add(const EditorChangeMode(EditorMode.normal));
      return;
    }

    switch (key) {
      case 'h':
        add(const EditorMoveCursor(columns: -1));
        break;
      case 'j':
        add(const EditorMoveCursor(lines: 1));
        break;
      case 'k':
        add(const EditorMoveCursor(lines: -1));
        break;
      case 'l':
        add(const EditorMoveCursor(columns: 1));
        break;
      case 'd':
        add(const EditorDeleteSelection());
        add(const EditorChangeMode(EditorMode.normal));
        break;
      case 'y':
        add(const EditorYank(isLine: false));
        add(const EditorChangeMode(EditorMode.normal));
        break;
    }
  }

  void _handleCommandModeKey(
    EditorInputKey event,
    EditorReady state,
    BufferEntity buffer,
  ) {
    if (event.key == 'Escape') {
      add(const EditorCancelCommand());
      return;
    }

    if (event.key == 'Enter') {
      add(const EditorExecuteCommand());
      return;
    }

    if (event.key == 'Backspace') {
      if (buffer.commandBuffer.isNotEmpty) {
        _updateActiveBuffer(state, buffer.copyWith(
          commandBuffer: buffer.commandBuffer.substring(0, buffer.commandBuffer.length - 1),
        ));
      } else {
        add(const EditorCancelCommand());
      }
      return;
    }

    if (event.key.length == 1) {
      _updateActiveBuffer(state, buffer.copyWith(
        commandBuffer: buffer.commandBuffer + event.key,
      ));
    }
  }

  void _onMoveCursor(
    EditorMoveCursor event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final newLine = (buffer.cursor.line + event.lines).clamp(0, buffer.lineCount - 1);
    final targetLine = buffer.lines[newLine];
    final newColumn = min(
      buffer.cursor.column + event.columns,
      max(0, targetLine.length - 1),
    ).toInt();

    final newBuffer = buffer.copyWith(
      cursor: CursorPosition(line: newLine, column: newColumn),
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onMoveToLine(
    EditorMoveToLine event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final newLine = event.line.clamp(0, buffer.lineCount - 1);
    final targetLine = buffer.lines[newLine];
    final clamped = event.column?.clamp(0, max(0, targetLine.length));
    final newColumn = (clamped is int ? clamped : clamped?.toInt()) ?? buffer.cursor.column;

    final newBuffer = buffer.copyWith(
      cursor: CursorPosition(line: newLine, column: newColumn),
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onInsertText(
    EditorInsertText event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final before = currentLine.substring(0, buffer.cursor.column);
    final after = currentLine.substring(buffer.cursor.column);

    lines[buffer.cursor.line] = before + event.text + after;

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);
    final newUndoIndex = newUndoStack.length - 1;

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(
        line: buffer.cursor.line,
        column: buffer.cursor.column + event.text.length,
      ),
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoIndex,
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onDeleteBackward(
    EditorDeleteBackward event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    if (buffer.cursor.column == 0 && buffer.cursor.line > 0) {
      final lines = List<String>.from(buffer.lines);
      final prevLine = lines[buffer.cursor.line - 1];
      final currentLine = lines[buffer.cursor.line];
      
      lines[buffer.cursor.line - 1] = prevLine + currentLine;
      lines.removeAt(buffer.cursor.line);

      final newContent = lines.join('\n');
      final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

      final newBuffer = buffer.copyWith(
        content: newContent,
        cursor: CursorPosition(
          line: buffer.cursor.line - 1,
          column: prevLine.length,
        ),
        isModified: true,
        undoStack: newUndoStack,
        undoIndex: newUndoStack.length - 1,
      );

      _updateActiveBuffer(currentState, newBuffer);
    } else if (buffer.cursor.column > 0) {
      final lines = List<String>.from(buffer.lines);
      final currentLine = lines[buffer.cursor.line];
      
      lines[buffer.cursor.line] = currentLine.substring(0, buffer.cursor.column - 1) +
          currentLine.substring(buffer.cursor.column);

      final newContent = lines.join('\n');
      final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

      final newBuffer = buffer.copyWith(
        content: newContent,
        cursor: CursorPosition(
          line: buffer.cursor.line,
          column: buffer.cursor.column - 1,
        ),
        isModified: true,
        undoStack: newUndoStack,
        undoIndex: newUndoStack.length - 1,
      );

      _updateActiveBuffer(currentState, newBuffer);
    }
  }

  void _onDeleteForward(
    EditorDeleteForward event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    
    if (buffer.cursor.column < currentLine.length) {
      lines[buffer.cursor.line] = currentLine.substring(0, buffer.cursor.column) +
          currentLine.substring(buffer.cursor.column + event.count);

      final newContent = lines.join('\n');
      final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

      final newBuffer = buffer.copyWith(
        content: newContent,
        isModified: true,
        undoStack: newUndoStack,
        undoIndex: newUndoStack.length - 1,
      );

      _updateActiveBuffer(currentState, newBuffer);
    }
  }

  void _onDeleteLine(
    EditorDeleteLine event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    if (buffer.lineCount <= 1) {
      final newBuffer = buffer.copyWith(
        content: '',
        cursor: const CursorPosition(line: 0, column: 0),
        isModified: true,
      );
      _updateActiveBuffer(currentState, newBuffer);
      return;
    }

    final lines = List<String>.from(buffer.lines);
    final deletedLine = lines[buffer.cursor.line];
    lines.removeAt(buffer.cursor.line);

    final newLine = min(buffer.cursor.line, lines.length - 1);
    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(line: newLine, column: 0),
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    emit(currentState.copyWith(
      clipboard: deletedLine,
    ));
    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onChangeMode(
    EditorChangeMode event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    Selection? selection;
    if (event.mode == EditorMode.visual ||
        event.mode == EditorMode.visualLine) {
      selection = Selection(
        start: buffer.cursor,
        end: buffer.cursor,
      );
    }

    final newBuffer = buffer.copyWith(
      mode: event.mode,
      selection: selection,
      commandBuffer: event.mode == EditorMode.command ? ':' : '',
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onUndo(
    EditorUndo event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    if (buffer.undoIndex > 0) {
      final newUndoIndex = buffer.undoIndex - 1;
      final previousContent = buffer.undoStack[newUndoIndex];

      final newBuffer = buffer.copyWith(
        content: previousContent,
        undoIndex: newUndoIndex,
        isModified: newUndoIndex > 0,
      );

      _updateActiveBuffer(currentState, newBuffer);
    }
  }

  void _onRedo(
    EditorRedo event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    if (buffer.undoIndex < buffer.undoStack.length - 1) {
      final newUndoIndex = buffer.undoIndex + 1;
      final nextContent = buffer.undoStack[newUndoIndex];

      final newBuffer = buffer.copyWith(
        content: nextContent,
        undoIndex: newUndoIndex,
        isModified: true,
      );

      _updateActiveBuffer(currentState, newBuffer);
    }
  }

  void _onYank(
    EditorYank event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    String yankedText;
    if (event.isLine) {
      yankedText = buffer.currentLine + '\n';
    } else if (buffer.selection != null) {
      yankedText = _getSelectedText(buffer);
    } else {
      yankedText = buffer.currentLine[buffer.cursor.column];
    }

    emit(currentState.copyWith(clipboard: yankedText));
  }

  void _onPaste(
    EditorPaste event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final clipboard = currentState.clipboard;
    if (clipboard == null || clipboard.isEmpty) return;

    final insertColumn = event.after
        ? min(buffer.cursor.column + 1, buffer.currentLineLength)
        : buffer.cursor.column;

    add(EditorMoveToLine(buffer.cursor.line, column: insertColumn));
    add(EditorInsertText(clipboard));
  }

  void _onDeleteSelection(
    EditorDeleteSelection event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    if (buffer.selection == null) return;

    final selectedText = _getSelectedText(buffer);
    emit(currentState.copyWith(clipboard: selectedText));

    final lines = List<String>.from(buffer.lines);
    final startLine = min(buffer.selection!.start.line, buffer.selection!.end.line);
    final endLine = max(buffer.selection!.start.line, buffer.selection!.end.line);
    final startCol = min(buffer.selection!.start.column, buffer.selection!.end.column);
    final endCol = max(buffer.selection!.start.column, buffer.selection!.end.column);

    if (startLine == endLine) {
      final line = lines[startLine];
      lines[startLine] = line.substring(0, startCol) + line.substring(endCol + 1);
    } else {
      final firstLine = lines[startLine];
      final lastLine = lines[endLine];
      lines[startLine] = firstLine.substring(0, startCol) + lastLine.substring(endCol + 1);
      
      for (var i = endLine; i > startLine; i--) {
        lines.removeAt(i);
      }
    }

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(line: startLine, column: startCol),
      selection: null,
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onCommandInput(
    EditorCommandInput event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final newBuffer = buffer.copyWith(
      commandBuffer: buffer.commandBuffer + event.key,
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onExecuteCommand(
    EditorExecuteCommand event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final cmd = buffer.commandBuffer;
    
    if (cmd == ':w' || cmd == ':write') {
      add(EditorSaveBuffer(path: buffer.filePath));
    } else if (cmd.startsWith(':w ')) {
      final path = cmd.substring(3).trim();
      add(EditorSaveBuffer(path: path));
    } else if (cmd == ':q' || cmd == ':quit') {
      if (!buffer.isModified) {
        add(EditorCloseBuffer(buffer.id));
      }
    } else if (cmd == ':q!' || cmd == ':quit!') {
      add(EditorCloseBuffer(buffer.id));
    } else if (cmd == ':wq' || cmd == ':x' || cmd == ':wq!' || cmd == ':x!') {
      add(EditorSaveBuffer(path: buffer.filePath));
      add(EditorCloseBuffer(buffer.id));
    } else if (cmd == ':e!' || cmd == ':edit!') {
      if (buffer.filePath != null) {
        add(EditorLoadFile(buffer.filePath!));
      }
    } else if (cmd == ':e' || cmd == ':edit') {
      add(EditorSaveBuffer(path: buffer.filePath));
    } else if (RegExp(r':\d+').hasMatch(cmd)) {
      final lineNum = int.parse(cmd.substring(1)) - 1;
      add(EditorMoveToLine(lineNum, column: 0));
    } else if (cmd == ':new' || cmd == ':tabnew') {
      add(const EditorNewBuffer());
    } else if (cmd.startsWith(':split ')) {
      final path = cmd.substring(7).trim();
      add(EditorLoadFile(path));
    } else if (cmd == ':vsplit' || cmd == ':vs') {
      add(const EditorNewBuffer());
    } else if (cmd == ':marks') {
      emit(currentState.copyWith(
        statusMessage: 'Marcadores: ${_marks.keys.isEmpty ? "nenhum" : _marks.keys.join(", ")}',
      ));
      Future.delayed(const Duration(seconds: 3), () {
        if (state is EditorReady) {
          emit((state as EditorReady).copyWith(statusMessage: null));
        }
      });
    } else if (cmd == ':help' || cmd == ':h') {
      emit(currentState.copyWith(
        statusMessage: ':w :q :wq :e :new :split :marks :help :tabnew :vs',
      ));
      Future.delayed(const Duration(seconds: 5), () {
        if (state is EditorReady) {
          emit((state as EditorReady).copyWith(statusMessage: null));
        }
      });
    } else if (cmd.startsWith(':set ')) {
      emit(currentState.copyWith(
        statusMessage: 'Configuração aplicada',
      ));
      Future.delayed(const Duration(seconds: 2), () {
        if (state is EditorReady) {
          emit((state as EditorReady).copyWith(statusMessage: null));
        }
      });
    }

    final newBuffer = buffer.copyWith(
      mode: EditorMode.normal,
      commandBuffer: '',
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onCancelCommand(
    EditorCancelCommand event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final newBuffer = buffer.copyWith(
      mode: EditorMode.normal,
      commandBuffer: '',
      selection: null,
    );

    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onSearch(
    EditorSearch event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final matches = _findAllMatches(buffer.content, event.pattern);
    
    if (matches.isNotEmpty) {
      final startIndex = event.forward ? 0 : matches.length - 1;
      final match = matches[startIndex];
      
      final lines = buffer.content.substring(0, match.start).split('\n');
      final line = lines.length - 1;
      final col = lines.last.length;

      final newBuffer = buffer.copyWith(
        cursor: CursorPosition(line: line, column: col),
      );

      emit(currentState.copyWith(
        searchPattern: event.pattern,
        searchIndex: startIndex,
      ));
      _updateActiveBuffer(currentState, newBuffer);
    }
  }

  void _onFindNext(
    EditorFindNext event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final pattern = currentState.searchPattern;
    if (pattern == null) return;

    final matches = _findAllMatches(buffer.content, pattern);
    if (matches.isEmpty) return;

    final nextIndex = (currentState.searchIndex + 1) % matches.length;
    final match = matches[nextIndex];

    final lines = buffer.content.substring(0, match.start).split('\n');
    final line = lines.length - 1;
    final col = lines.last.length;

    final newBuffer = buffer.copyWith(
      cursor: CursorPosition(line: line, column: col),
    );

    emit(currentState.copyWith(searchIndex: nextIndex));
    _updateActiveBuffer(currentState, newBuffer);
  }

  void _onFindPrevious(
    EditorFindPrevious event,
    Emitter<EditorState> emit,
  ) {
    if (state is! EditorReady) return;
    final currentState = state as EditorReady;
    final buffer = currentState.activeBuffer;

    final pattern = currentState.searchPattern;
    if (pattern == null) return;

    final matches = _findAllMatches(buffer.content, pattern);
    if (matches.isEmpty) return;

    final prevIndex = (currentState.searchIndex - 1 + matches.length) % matches.length;
    final match = matches[prevIndex];

    final lines = buffer.content.substring(0, match.start).split('\n');
    final line = lines.length - 1;
    final col = lines.last.length;

    final newBuffer = buffer.copyWith(
      cursor: CursorPosition(line: line, column: col),
    );

    emit(currentState.copyWith(searchIndex: prevIndex));
    _updateActiveBuffer(currentState, newBuffer);
  }

  List<Match> _findAllMatches(String content, String pattern) {
    try {
      final regex = RegExp(pattern, caseSensitive: false);
      return regex.allMatches(content).toList();
    } catch (e) {
      return [];
    }
  }

  String _getSelectedText(BufferEntity buffer) {
    if (buffer.selection == null) return '';

    final lines = buffer.lines;
    final startLine = min(buffer.selection!.start.line, buffer.selection!.end.line);
    final endLine = max(buffer.selection!.start.line, buffer.selection!.end.line);
    final startCol = min(buffer.selection!.start.column, buffer.selection!.end.column);
    final endCol = max(buffer.selection!.start.column, buffer.selection!.end.column);

    if (startLine == endLine) {
      final line = lines[startLine];
      return line.substring(startCol, endCol + 1);
    } else {
      final selectedLines = <String>[];
      selectedLines.add(lines[startLine].substring(startCol));
      for (var i = startLine + 1; i < endLine; i++) {
        selectedLines.add(lines[i]);
      }
      selectedLines.add(lines[endLine].substring(0, endCol + 1));
      return selectedLines.join('\n');
    }
  }

  void _insertNewline(EditorReady state, BufferEntity buffer) {
    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final before = currentLine.substring(0, buffer.cursor.column);
    final after = currentLine.substring(buffer.cursor.column);

    final leadingWhitespace = RegExp(r'^\s*').firstMatch(before)?.group(0) ?? '';

    lines[buffer.cursor.line] = before;
    lines.insert(buffer.cursor.line + 1, leadingWhitespace + after);

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(
        line: buffer.cursor.line + 1,
        column: leadingWhitespace.length,
      ),
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(state, newBuffer);
  }

  void _openLineBelow(EditorReady state, BufferEntity buffer) {
    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final leadingWhitespace = RegExp(r'^\s*').firstMatch(currentLine)?.group(0) ?? '';

    lines.insert(buffer.cursor.line + 1, leadingWhitespace);

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(
        line: buffer.cursor.line + 1,
        column: leadingWhitespace.length,
      ),
      mode: EditorMode.insert,
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(state, newBuffer);
  }

  void _openLineAbove(EditorReady state, BufferEntity buffer) {
    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final leadingWhitespace = RegExp(r'^\s*').firstMatch(currentLine)?.group(0) ?? '';

    lines.insert(buffer.cursor.line, leadingWhitespace);

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(
        line: buffer.cursor.line,
        column: leadingWhitespace.length,
      ),
      mode: EditorMode.insert,
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(state, newBuffer);
  }

  void _moveWordForward(EditorReady state, BufferEntity buffer) {
    final line = buffer.currentLine;
    final column = buffer.cursor.column;

    if (column >= line.length - 1) {
      if (buffer.cursor.line < buffer.lineCount - 1) {
        add(EditorMoveToLine(buffer.cursor.line + 1, column: 0));
      }
      return;
    }

    final wordStart = _findNextWordStart(line, column + 1);
    add(EditorMoveToLine(buffer.cursor.line, column: wordStart));
  }

  void _moveWordBackward(EditorReady state, BufferEntity buffer) {
    final line = buffer.currentLine;
    final column = buffer.cursor.column;

    if (column <= 0) {
      if (buffer.cursor.line > 0) {
        final prevLine = buffer.lines[buffer.cursor.line - 1];
        add(EditorMoveToLine(buffer.cursor.line - 1, column: max(0, prevLine.length - 1)));
      }
      return;
    }

    final wordStart = _findPrevWordStart(line, column - 1);
    add(EditorMoveToLine(buffer.cursor.line, column: wordStart));
  }

  void _moveWordEnd(EditorReady state, BufferEntity buffer) {
    final line = buffer.currentLine;
    final column = buffer.cursor.column;

    if (column >= line.length - 1) {
      if (buffer.cursor.line < buffer.lineCount - 1) {
        add(EditorMoveToLine(buffer.cursor.line + 1, column: 0));
      }
      return;
    }

    final wordEnd = _findWordEnd(line, column + 1);
    add(EditorMoveToLine(buffer.cursor.line, column: wordEnd));
  }

  int _findNextWordStart(String line, int start) {
    bool inWord = _isWordChar(line[max(0, start - 1)]);
    
    for (var i = start; i < line.length; i++) {
      final isWord = _isWordChar(line[i]);
      if (!inWord && isWord) {
        return i;
      }
      inWord = isWord;
    }
    
    return line.length - 1;
  }

  int _findPrevWordStart(String line, int start) {
    bool inWord = _isWordChar(line[start]);
    
    for (var i = start; i >= 0; i--) {
      final isWord = _isWordChar(line[i]);
      if (!inWord && isWord) {
        return i;
      }
      inWord = isWord;
    }
    
    return 0;
  }

  int _findWordEnd(String line, int start) {
    bool inWord = _isWordChar(line[start]);
    
    for (var i = start; i < line.length; i++) {
      final isWord = _isWordChar(line[i]);
      if (inWord && !isWord) {
        return i - 1;
      }
      inWord = isWord;
    }
    
    return line.length - 1;
  }

  bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Z0-9_]').hasMatch(char);
  }

  void _jumpBack(EditorReady state, BufferEntity buffer) {
    if (_jumpIndex > 0) {
      _jumpIndex--;
      final pos = _jumpList[_jumpIndex];
      final newBuffer = buffer.copyWith(
        cursor: CursorPosition(line: pos.line, column: pos.column),
      );
      _updateActiveBuffer(state, newBuffer);
    }
  }

  void _jumpForward(EditorReady state, BufferEntity buffer) {
    if (_jumpIndex < _jumpList.length - 1) {
      _jumpIndex++;
      final pos = _jumpList[_jumpIndex];
      final newBuffer = buffer.copyWith(
        cursor: CursorPosition(line: pos.line, column: pos.column),
      );
      _updateActiveBuffer(state, newBuffer);
    }
  }

  void _addJump(BufferEntity buffer) {
    _jumpList.add(buffer.cursor);
    if (_jumpList.length > 100) {
      _jumpList.removeAt(0);
    }
    _jumpIndex = _jumpList.length - 1;
  }

  void _joinLines(EditorReady state, BufferEntity buffer) {
    if (buffer.cursor.line >= buffer.lineCount - 1) return;

    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final nextLine = lines[buffer.cursor.line + 1];

    lines[buffer.cursor.line] = '$currentLine ${nextLine.trimLeft()}';
    lines.removeAt(buffer.cursor.line + 1);

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      cursor: CursorPosition(
        line: buffer.cursor.line,
        column: currentLine.length + 1,
      ),
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(state, newBuffer);
  }

  void _repeatLastChange(EditorReady state, BufferEntity buffer) {
    if (_lastChange.isNotEmpty) {
      add(EditorInsertText(_lastChange));
    }
  }

  void _toggleCase(EditorReady state, BufferEntity buffer) {
    final lines = List<String>.from(buffer.lines);
    final currentLine = lines[buffer.cursor.line];
    final col = buffer.cursor.column;

    if (col < currentLine.length) {
      final char = currentLine[col];
      final toggled = char == char.toUpperCase()
          ? char.toLowerCase()
          : char.toUpperCase();

      lines[buffer.cursor.line] =
          currentLine.substring(0, col) + toggled + currentLine.substring(col + 1);

      final newContent = lines.join('\n');
      final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

      final newBuffer = buffer.copyWith(
        content: newContent,
        cursor: CursorPosition(
          line: buffer.cursor.line,
          column: col + 1,
        ),
        isModified: true,
        undoStack: newUndoStack,
        undoIndex: newUndoStack.length - 1,
      );

      _updateActiveBuffer(state, newBuffer);
    }
  }

  void _indentLine(EditorReady state, BufferEntity buffer, {required bool decrease}) {
    final lines = List<String>.from(buffer.lines);
    final line = lines[buffer.cursor.line];

    if (decrease) {
      if (line.startsWith('  ')) {
        lines[buffer.cursor.line] = line.substring(2);
      } else if (line.startsWith('\t')) {
        lines[buffer.cursor.line] = line.substring(1);
      }
    } else {
      lines[buffer.cursor.line] = '  $line';
    }

    final newContent = lines.join('\n');
    final newUndoStack = _addToUndoStack(buffer.undoStack, buffer.undoIndex, buffer.content);

    final newBuffer = buffer.copyWith(
      content: newContent,
      isModified: true,
      undoStack: newUndoStack,
      undoIndex: newUndoStack.length - 1,
    );

    _updateActiveBuffer(state, newBuffer);
  }

  void _startSearch(EditorReady state, BufferEntity buffer, {required bool forward}) {
    final newBuffer = buffer.copyWith(
      mode: EditorMode.command,
      commandBuffer: forward ? '/' : '?',
    );
    _updateActiveBuffer(state, newBuffer);
  }

  List<String> _addToUndoStack(List<String> stack, int currentIndex, String content) {
    final newStack = List<String>.from(stack.take(currentIndex + 1));
    newStack.add(content);
    if (newStack.length > 1000) {
      newStack.removeAt(0);
    }
    return newStack;
  }

  String? _getFileType(String fileName) {
    final ext = '.${fileName.split('.').last.toLowerCase()}';
    const typeMap = {
      '.dart': 'dart',
      '.js': 'javascript',
      '.jsx': 'javascript',
      '.ts': 'typescript',
      '.tsx': 'typescript',
      '.py': 'python',
      '.java': 'java',
      '.kt': 'kotlin',
      '.go': 'go',
      '.rs': 'rust',
      '.c': 'c',
      '.cpp': 'cpp',
      '.h': 'c',
      '.hpp': 'cpp',
      '.html': 'html',
      '.htm': 'html',
      '.css': 'css',
      '.scss': 'scss',
      '.sass': 'scss',
      '.json': 'json',
      '.yaml': 'yaml',
      '.yml': 'yaml',
      '.md': 'markdown',
      '.sql': 'sql',
      '.sh': 'bash',
      '.bash': 'bash',
      '.zsh': 'bash',
      '.php': 'php',
      '.rb': 'ruby',
      '.swift': 'swift',
      '.lua': 'lua',
      '.vim': 'vim',
    };
    return typeMap[ext];
  }
}
