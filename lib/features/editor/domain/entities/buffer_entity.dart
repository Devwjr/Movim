import 'package:equatable/equatable.dart';

enum EditorMode {
  normal,
  insert,
  visual,
  visualLine,
  visualBlock,
  command,
}

class CursorPosition extends Equatable {
  final int line;
  final int column;

  const CursorPosition({
    this.line = 0,
    this.column = 0,
  });

  @override
  List<Object?> get props => [line, column];

  CursorPosition copyWith({
    int? line,
    int? column,
  }) {
    return CursorPosition(
      line: line ?? this.line,
      column: column ?? this.column,
    );
  }
}

class Selection extends Equatable {
  final CursorPosition start;
  final CursorPosition end;

  const Selection({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];

  Selection copyWith({
    CursorPosition? start,
    CursorPosition? end,
  }) {
    return Selection(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class BufferEntity extends Equatable {
  final String id;
  final String? filePath;
  final String? fileName;
  final String content;
  final EditorMode mode;
  final CursorPosition cursor;
  final Selection? selection;
  final String commandBuffer;
  final bool isModified;
  final bool isReadOnly;
  final String? fileType;
  final int tabSize;
  final bool expandTabs;
  final List<String> undoStack;
  final int undoIndex;

  const BufferEntity({
    required this.id,
    this.filePath,
    this.fileName,
    this.content = '',
    this.mode = EditorMode.normal,
    this.cursor = const CursorPosition(),
    this.selection,
    this.commandBuffer = '',
    this.isModified = false,
    this.isReadOnly = false,
    this.fileType,
    this.tabSize = 2,
    this.expandTabs = true,
    this.undoStack = const [''],
    this.undoIndex = 0,
  });

  @override
  List<Object?> get props => [
        id,
        filePath,
        fileName,
        content,
        mode,
        cursor,
        selection,
        commandBuffer,
        isModified,
        isReadOnly,
        fileType,
        tabSize,
        expandTabs,
        undoStack,
        undoIndex,
      ];

  List<String> get lines {
    return content.replaceAll('\r\n', '\n').split('\n');
  }

  int get lineCount => lines.length;

  String get currentLine {
    final lineList = lines;
    if (cursor.line >= 0 && cursor.line < lineList.length) {
      return lineList[cursor.line];
    }
    return '';
  }

  int get currentLineLength => currentLine.length;

  BufferEntity copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? content,
    EditorMode? mode,
    CursorPosition? cursor,
    Selection? selection,
    String? commandBuffer,
    bool? isModified,
    bool? isReadOnly,
    String? fileType,
    int? tabSize,
    bool? expandTabs,
    List<String>? undoStack,
    int? undoIndex,
  }) {
    return BufferEntity(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      content: content ?? this.content,
      mode: mode ?? this.mode,
      cursor: cursor ?? this.cursor,
      selection: selection ?? this.selection,
      commandBuffer: commandBuffer ?? this.commandBuffer,
      isModified: isModified ?? this.isModified,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      fileType: fileType ?? this.fileType,
      tabSize: tabSize ?? this.tabSize,
      expandTabs: expandTabs ?? this.expandTabs,
      undoStack: undoStack ?? this.undoStack,
      undoIndex: undoIndex ?? this.undoIndex,
    );
  }
}
