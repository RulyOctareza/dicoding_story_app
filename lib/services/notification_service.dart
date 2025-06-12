import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> showStoryNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'story_channel',
          'Story Notifications',
          channelDescription: 'Notification for new stories',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _plugin.show(
      0,
      'Seseorang upload story baru',
      'Buka aplikasi untuk melihat cerita terbaru!',
      details,
    );
  }

  static Future<void> scheduleStoryNotification() async {
    await _plugin.periodicallyShow(
      1,
      'Seseorang upload story baru',
      'Buka aplikasi untuk melihat cerita terbaru!',
      RepeatInterval.hourly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'story_channel',
          'Story Notifications',
          channelDescription: 'Notification for new stories',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
