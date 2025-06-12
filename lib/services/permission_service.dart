import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    developer.log(
      'Requesting notification permission...',
      name: 'PermissionService',
    );

    // For Android 13 and above (API level 33)
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      developer.log(
        'Notification permission status: $status',
        name: 'PermissionService',
      );
      return status.isGranted;
    }

    // Permission is already granted
    return true;
  }

  static Future<bool> checkNotificationPermission() async {
    developer.log(
      'Checking notification permission...',
      name: 'PermissionService',
    );

    final status = await Permission.notification.status;
    developer.log(
      'Notification permission status: $status',
      name: 'PermissionService',
    );
    return status.isGranted;
  }
}
