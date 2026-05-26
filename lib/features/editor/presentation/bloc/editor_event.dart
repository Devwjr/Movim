import 'package:equatable/equatable.dart';
import '../../domain/entities/buffer_entity.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class EditorLoadFile extends EditorEvent {
  final String path;

  const EditorLoadFile(this.path);

  @override
  List<Object?> get props => [path];
}

class EditorNewBuffer extends EditorEvent {
  final String? fileName;

  const EditorNewBuffer({this.fileName});

  @override
  List<Object?> get props => [fileName];
}

class EditorSaveBuffer extends EditorEvent {
  final String? path;

  const EditorSaveBuffer({this.path});

  @override
  List<Object?> get props => [path];
}

class EditorCloseBuffer extends EditorEvent {
  final String bufferId;

  const EditorCloseBuffer(this.bufferId);

  @override
  List<Object?> get props => [bufferId];
}

class EditorSwitchBuffer extends EditorEvent {
  final String bufferId;

  const EditorSwitchBuffer(this.bufferId);

  @override
  List<Object?> get props => [bufferId];
}

class EditorInputKey extends EditorEvent {
  final String key;
  final bool isShift;
  final bool isControl;
  final bool isAlt;

  const EditorInputKey({
    required this.key,
    this.isShift = false,
    this.isControl = false,
    this.isAlt = false,
  });

  @override
  List<Object?> get props => [key, isShift, isControl, isAlt];
}

class EditorMoveCursor extends EditorEvent {
  final int lines;
  final int columns;

  const EditorMoveCursor({
    this.lines = 0,
    this.columns = 0,
  });

  @override
  List<Object?> get props => [lines, columns];
}

class EditorMoveToLine extends EditorEvent {
  final int line;
  final int? column;

  const EditorMoveToLine(this.line, {this.column});

  @override
  List<Object?> get props => [line, column];
}

class EditorInsertText extends EditorEvent {
  final String text;

  const EditorInsertText(this.text);

  @override
  List<Object?> get props => [text];
}

class EditorDeleteBackward extends EditorEvent {
  final int count;

  const EditorDeleteBackward({this.count = 1});

  @override
  List<Object?> get props => [count];
}

class EditorDeleteForward extends EditorEvent {
  final int count;

  const EditorDeleteForward({this.count = 1});

  @override
  List<Object?> get props => [count];
}

class EditorDeleteLine extends EditorEvent {
  final int? line;
  final int count;

  const EditorDeleteLine({this.line, this.count = 1});

  @override
  List<Object?> get props => [line, count];
}

class EditorChangeMode extends EditorEvent {
  final EditorMode mode;

  const EditorChangeMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class EditorUndo extends EditorEvent {
  const EditorUndo();
}

class EditorRedo extends EditorEvent {
  const EditorRedo();
}

class EditorYank extends EditorEvent {
  final bool isLine;
  final int count;

  const EditorYank({
    this.isLine = false,
    this.count = 1,
  });

  @override
  List<Object?> get props => [isLine, count];
}

class EditorPaste extends EditorEvent {
  final bool after;

  const EditorPaste({this.after = true});

  @override
  List<Object?> get props => [after];
}

class EditorDeleteSelection extends EditorEvent {
  const EditorDeleteSelection();
}

class EditorCommandInput extends EditorEvent {
  final String key;

  const EditorCommandInput(this.key);

  @override
  List<Object?> get props => [key];
}

class EditorExecuteCommand extends EditorEvent {
  const EditorExecuteCommand();
}

class EditorCancelCommand extends EditorEvent {
  const EditorCancelCommand();
}

class EditorSearch extends EditorEvent {
  final String pattern;
  final bool forward;

  const EditorSearch({
    required this.pattern,
    this.forward = true,
  });

  @override
  List<Object?> get props => [pattern, forward];
}

class EditorFindNext extends EditorEvent {
  const EditorFindNext();
}

class EditorFindPrevious extends EditorEvent {
  const EditorFindPrevious();
}

class EditorScroll extends EditorEvent {
  final int lines;

  const EditorScroll(this.lines);

  @override
  List<Object?> get props => [lines];
}
