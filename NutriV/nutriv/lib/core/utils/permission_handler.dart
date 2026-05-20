import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Request camera permission and return whether it was granted
  static Future<bool> requestCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return true; // Assume granted on other platforms
  }

  /// Check if camera permission is already granted
  static Future<bool> checkCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.status;
      return status.isGranted;
    }
    return true; // Assume granted on other platforms
  }

  /// Request storage permission and return whether it was granted
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // Assume granted on other platforms
  }

  /// Check if storage permission is already granted
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
    return true; // Assume granted on other platforms
  }

  /// Request multiple permissions and return results
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await permissions.request();
    }
    // Return granted for all permissions on other platforms
    final Map<Permission, PermissionStatus> result = {};
    for (final permission in permissions) {
      result[permission] = PermissionStatus.granted;
    }
    return result;
  }
}