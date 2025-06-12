import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isEnabled = true;
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
    _isEnabled = prefs.getBool('notifications_enabled') ?? true;
    developer.log(
      'Loaded notification preference: $_isEnabled',
      name: 'NotificationProvider',
    );
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _isEnabled = !_isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _isEnabled);

    if (_isEnabled) {
      await NotificationService.scheduleStoryNotification();
      developer.log('Notifications enabled', name: 'NotificationProvider');
    } else {
      await NotificationService.cancelAllNotifications();
      developer.log('Notifications disabled', name: 'NotificationProvider');
    }

    notifyListeners();
  }
}
