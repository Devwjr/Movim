import 'dart:io';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

class Helpers {
  static String getFileExtension(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ext;
  }

  static String? getLanguageFromExtension(String extension) {
    return AppConstants.fileExtensions[extension.toLowerCase()];
  }

  static String? getLanguageFromPath(String filePath) {
    final ext = getFileExtension(filePath);
    return getLanguageFromExtension(ext);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes}m atrás';
      }
      return '${difference.inHours}h atrás';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String truncateString(String text, {int maxLength = 30}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  static List<String> splitLines(String content) {
    return content.replaceAll('\r\n', '\n').split('\n');
  }

  static int countLines(String content) {
    return splitLines(content).length;
  }

  static String escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }

  static bool isBinaryFile(File file) {
    try {
      final bytes = file.readAsBytesSync();
      for (var i = 0; i < bytes.length && i < 1024; i++) {
        if (bytes[i] == 0) return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  static String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  static String getParentDirectory(String path) {
    final parts = path.split(Platform.pathSeparator);
    parts.removeLast();
    return parts.join(Platform.pathSeparator);
  }

  static bool isValidFileName(String name) {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(name) && name.trim().isNotEmpty;
  }

  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }

  static List<String> getVisibleFiles(List<FileSystemEntity> entities) {
    return entities
        .where((e) {
          final name = getFileName(e.path);
          return !name.startsWith('.');
        })
        .map((e) => e.path)
        .toList();
  }

  static int comparePaths(String a, String b, bool directoriesFirst) {
    final aIsDir = Directory(a).existsSync();
    final bIsDir = Directory(b).existsSync();

    if (directoriesFirst) {
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
    }

    return getFileName(a).toLowerCase().compareTo(getFileName(b).toLowerCase());
  }
}
