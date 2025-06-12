import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/story_service.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    developer.log(
      'Background task started: $taskName',
      name: 'BackgroundService',
    );

    try {
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (!notificationsEnabled) {
        developer.log(
          'Notifications are disabled, skipping background task',
          name: 'BackgroundService',
        );
        return Future.value(true);
      }

      switch (taskName) {
        case BackgroundService.checkNewStoriesTask:
          final token = prefs.getString('token');
          if (token == null) {
            developer.log(
              'No token found, skipping background task',
              name: 'BackgroundService',
            );
            return Future.value(true);
          }

          final storyService = StoryService();
          final stories = await storyService.fetchStories(token);

          if (stories.isNotEmpty) {
            final lastStoryId = prefs.getString('last_story_id');
            final latestStory = stories.first;

            if (lastStoryId != null && lastStoryId != latestStory.id) {
              await NotificationService.showStoryNotification();
              await prefs.setString('last_story_id', latestStory.id);
            }
          }
          break;
      }

      return Future.value(true);
    } catch (e) {
      developer.log(
        'Background task failed',
        name: 'BackgroundService',
        error: e,
      );
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static const String checkNewStoriesTask = 'checkNewStories';

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    developer.log(
      'Initializing background service...',
      name: 'BackgroundService',
    );

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static Future<void> registerPeriodicTask() async {
    developer.log('Registering periodic task...', name: 'BackgroundService');

    await Workmanager().registerPeriodicTask(
      checkNewStoriesTask,
      checkNewStoriesTask,
      frequency: const Duration(minutes: 15), // Minimum interval allowed
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> cancelAllTasks() async {
    developer.log(
      'Cancelling all background tasks...',
      name: 'BackgroundService',
    );
    await Workmanager().cancelAll();
  }
}
