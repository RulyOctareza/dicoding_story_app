import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/background_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _prefKey = 'notifications_enabled';
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  NotificationProvider() {
    developer.log(
      'NotificationProvider initialized',
      name: 'NotificationProvider',
    );
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPreference = prefs.getBool(_prefKey) ?? false;

    // Check if we have permission when notifications were previously enabled
    if (savedPreference) {
      final hasPermission =
          await PermissionService.checkNotificationPermission();
      _isEnabled = hasPermission;
      if (_isEnabled) {
        // Re-register background task if notifications were enabled
        await BackgroundService.registerPeriodicTask();
      }
    } else {
      _isEnabled = false;
    }

    developer.log(
      'Loaded notification preference: $_isEnabled',
      name: 'NotificationProvider',
    );
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    try {
      if (!_isEnabled) {
        // Request permission when enabling notifications
        final hasPermission =
            await PermissionService.requestNotificationPermission();
        if (!hasPermission) {
          throw Exception('Notification permission denied');
        }
        // Register background task
        await BackgroundService.registerPeriodicTask();
      } else {
        // Cancel background task
        await BackgroundService.cancelAllTasks();
      }

      _isEnabled = !_isEnabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, _isEnabled);

      if (_isEnabled) {
        developer.log('Notifications enabled', name: 'NotificationProvider');
      } else {
        await NotificationService.cancelAllNotifications();
        developer.log('Notifications disabled', name: 'NotificationProvider');
      }

      notifyListeners();
    } catch (e) {
      developer.log(
        'Error toggling notifications',
        name: 'NotificationProvider',
        error: e,
      );
      // Revert the change if there was an error
      _isEnabled = !_isEnabled;
      await (await SharedPreferences.getInstance()).setBool(
        _prefKey,
        _isEnabled,
      );
      notifyListeners();
      rethrow;
    }
  }
}
