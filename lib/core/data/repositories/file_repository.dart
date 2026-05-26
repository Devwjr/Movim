import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class FileRepository {
  Future<String> readFile(String path);
  Future<void> writeFile(String path, String content);
  Future<void> deleteFile(String path);
  Future<bool> fileExists(String path);
  Future<File> createFile(String path);
  Future<Directory> createDirectory(String path);
  Future<void> deleteDirectory(String path, {bool recursive = false});
  Future<List<FileSystemEntity>> listDirectory(String path);
  Future<Directory> getAppDirectory();
  Future<Directory> getExternalStorageDirectory();
  Future<bool> requestStoragePermission();
  Future<bool> hasStoragePermission();
  Future<File> copyFile(String sourcePath, String destinationPath);
  Future<File> moveFile(String sourcePath, String destinationPath);
  Future<int> getFileSize(String path);
  Future<DateTime> getFileModifiedTime(String path);
  Future<String> readFileAsString(String path);
  Future<List<String>> readFileAsLines(String path);
}

class FileRepositoryImpl implements FileRepository {
  @override
  Future<String> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $path');
    }
    return await file.readAsString();
  }

  @override
  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content, flush: true);
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  @override
  Future<File> createFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  @override
  Future<Directory> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  Future<void> deleteDirectory(String path, {bool recursive = false}) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: recursive);
    }
  }

  @override
  Future<List<FileSystemEntity>> listDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw Exception('Diretório não encontrado: $path');
    }
    return directory.listSync();
  }

  @override
  Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      final directories = await getExternalStorageDirectories();
      return directories?.first ?? await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  @override
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      if (androidInfo.version.sdkInt >= 30) {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  @override
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      if (androidInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  @override
  Future<File> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Arquivo origem não encontrado: $sourcePath');
    }
    
    final destinationDir = Directory(destinationPath).parent;
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
    
    return await sourceFile.copy(destinationPath);
  }

  @override
  Future<File> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Arquivo origem não encontrado: $sourcePath');
    }
    
    final destinationDir = Directory(destinationPath).parent;
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
    
    return await sourceFile.rename(destinationPath);
  }

  @override
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $path');
    }
    return await file.length();
  }

  @override
  Future<DateTime> getFileModifiedTime(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $path');
    }
    return await file.lastModified();
  }

  @override
  Future<String> readFileAsString(String path) async {
    return readFile(path);
  }

  @override
  Future<List<String>> readFileAsLines(String path) async {
    final content = await readFile(path);
    return content.replaceAll('\r\n', '\n').split('\n');
  }
}

class DeviceInfoPlugin {
  Future<AndroidDeviceInfo> get androidInfo async {
    return AndroidDeviceInfo(
      version: AndroidVersion(
        sdkInt: 30,
      ),
    );
  }
}

class AndroidDeviceInfo {
  final AndroidVersion version;

  AndroidDeviceInfo({required this.version});
}

class AndroidVersion {
  final int sdkInt;

  AndroidVersion({required this.sdkInt});
}
