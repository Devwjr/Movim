import 'package:equatable/equatable.dart';
import '../../domain/entities/buffer_entity.dart';

abstract class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

class EditorInitial extends EditorState {
  const EditorInitial();
}

class EditorLoading extends EditorState {
  const EditorLoading();
}

class EditorReady extends EditorState {
  final List<BufferEntity> buffers;
  final String activeBufferId;
  final String? clipboard;
  final String? searchPattern;
  final int searchIndex;
  final String? statusMessage;

  const EditorReady({
    required this.buffers,
    required this.activeBufferId,
    this.clipboard,
    this.searchPattern,
    this.searchIndex = 0,
    this.statusMessage,
  });

  BufferEntity get activeBuffer {
    return buffers.firstWhere(
      (b) => b.id == activeBufferId,
      orElse: () => buffers.first,
    );
  }

  int get activeBufferIndex {
    return buffers.indexWhere((b) => b.id == activeBufferId);
  }

  @override
  List<Object?> get props => [
        buffers,
        activeBufferId,
        clipboard,
        searchPattern,
        searchIndex,
        statusMessage,
      ];

  EditorReady copyWith({
    List<BufferEntity>? buffers,
    String? activeBufferId,
    String? clipboard,
    String? searchPattern,
    int? searchIndex,
    String? statusMessage,
  }) {
    return EditorReady(
      buffers: buffers ?? this.buffers,
      activeBufferId: activeBufferId ?? this.activeBufferId,
      clipboard: clipboard ?? this.clipboard,
      searchPattern: searchPattern ?? this.searchPattern,
      searchIndex: searchIndex ?? this.searchIndex,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class EditorError extends EditorState {
  final String message;

  const EditorError(this.message);

  @override
  List<Object?> get props => [message];
}
