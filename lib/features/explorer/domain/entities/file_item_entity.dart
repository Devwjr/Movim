import 'package:equatable/equatable.dart';

enum FileType {
  directory,
  file,
  image,
  video,
  audio,
  document,
  archive,
  code,
  unknown,
}

enum SortType {
  name,
  size,
  date,
  type,
}

class FileItemEntity extends Equatable {
  final String path;
  final String name;
  final FileType type;
  final int size;
  final DateTime modifiedAt;
  final bool isHidden;

  const FileItemEntity({
    required this.path,
    required this.name,
    required this.type,
    this.size = 0,
    required this.modifiedAt,
    this.isHidden = false,
  });

  @override
  List<Object?> get props => [
        path,
        name,
        type,
        size,
        modifiedAt,
        isHidden,
      ];

  String get extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex > 0 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  bool get isDirectory => type == FileType.directory;
  bool get isFile => type != FileType.directory;
  bool get isImage => type == FileType.image;
  bool get isVideo => type == FileType.video;
  bool get isAudio => type == FileType.audio;
  bool get isCode => type == FileType.code;

  static FileType typeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    
    const imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico'};
    const videoExtensions = {'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'};
    const audioExtensions = {'mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'};
    const documentExtensions = {'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'};
    const archiveExtensions = {'zip', 'rar', '7z', 'tar', 'gz', 'bz2'};
    const codeExtensions = {
      'dart', 'js', 'ts', 'jsx', 'tsx', 'py', 'java', 'kt', 'go', 'rs',
      'c', 'cpp', 'h', 'hpp', 'html', 'css', 'scss', 'json', 'yaml', 'yml',
      'xml', 'md', 'sql', 'sh', 'bat', 'ps1', 'php', 'rb', 'swift', 'lua',
      'vim', 'toml', 'ini', 'cfg', 'conf',
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
