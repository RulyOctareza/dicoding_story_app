import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;
import 'permission_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    developer.log('Initializing notifications...', name: 'NotificationService');

    // Request permission for Android 13+
    final hasPermission =
        await PermissionService.requestNotificationPermission();
    if (!hasPermission) {
      developer.log(
        'Notification permission denied',
        name: 'NotificationService',
      );
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        developer.log(
          'Notification clicked: ${details.payload}',
          name: 'NotificationService',
        );
      },
    );
  }

  static Future<void> showStoryNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'story_updates',
          'Story Updates',
          channelDescription: 'Notifications for new story updates',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Story App',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Ada cerita baru!',
      'Buka aplikasi untuk melihat cerita terbaru',
      details,
    );
  }

  static Future<void> scheduleStoryNotification() async {
    developer.log(
      'Scheduling periodic notification',
      name: 'NotificationService',
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'story_updates',
          'Story Updates',
          channelDescription: 'Notifications for new story updates',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.periodicallyShow(
      1,
      'Story App',
      'Ada cerita baru yang menunggu untuk dibaca!',
      RepeatInterval.hourly,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    developer.log(
      'Periodic notification scheduled',
      name: 'NotificationService',
    );
  }

  static Future<void> cancelAllNotifications() async {
    developer.log('Cancelling all notifications', name: 'NotificationService');
    await _notificationsPlugin.cancelAll();
  }
}
