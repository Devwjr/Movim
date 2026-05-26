import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.mobilevim/permissions');

  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidSdkInt();
      
      if (androidInfo >= 30) {
        try {
          final result = await _channel.invokeMethod<bool>('checkStoragePermissions');
          return result ?? false;
        } on PlatformException {
          return await Permission.manageExternalStorage.isGranted;
        }
      } else {
        final readStatus = await Permission.storage.isGranted;
        return readStatus;
      }
    }
    return true;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidSdkInt();
      
      if (androidInfo >= 30) {
        try {
          await _channel.invokeMethod<void>('requestStoragePermissions');
          return await hasStoragePermission();
        } on PlatformException {
          final status = await Permission.manageExternalStorage.request();
          return status.isGranted;
        }
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on PlatformException {
      await openAppSettings();
    }
  }

  Future<void> openManageAllFilesAccess() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidSdkInt();
      if (androidInfo >= 30) {
        try {
          await _channel.invokeMethod<void>('openManageAllFilesAccess');
        } on PlatformException {
          await openAppSettings();
        }
      }
    }
  }

  Future<bool> requestAllRequiredPermissions() async {
    final storageGranted = await requestStoragePermission();
    
    if (!storageGranted) {
      return false;
    }

    final cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }

    final audioStatus = await Permission.microphone.status;
    if (audioStatus.isDenied) {
      await Permission.microphone.request();
    }

    return storageGranted;
  }

  Future<Map<String, PermissionStatus>> getAllPermissionStatuses() async {
    final statuses = <String, PermissionStatus>{};
    
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidSdkInt();
      
      if (androidInfo >= 33) {
        statuses['storage'] = await Permission.photos.isGranted 
            ? PermissionStatus.granted 
            : PermissionStatus.denied;
        statuses['mediaImages'] = await Permission.photos.status;
        statuses['mediaVideos'] = await Permission.videos.status;
        statuses['mediaAudio'] = await Permission.audio.status;
      } else {
        statuses['storage'] = await Permission.storage.status;
      }
      
      statuses['camera'] = await Permission.camera.status;
      statuses['microphone'] = await Permission.microphone.status;
      statuses['location'] = await Permission.location.status;
    }
    
    return statuses;
  }

  Future<int> _getAndroidSdkInt() async {
    if (!Platform.isAndroid) return 0;
    
    try {
      final deviceInfo = await const MethodChannel('plugins.flutter.io/device_info')
          .invokeMethod<Map>('getAndroidDeviceInfo');
      final sdkInt = deviceInfo?['version']?['sdkInt'];
      if (sdkInt is int) return sdkInt;
      return 21;
    } catch (e) {
      return 21;
    }
  }
}
