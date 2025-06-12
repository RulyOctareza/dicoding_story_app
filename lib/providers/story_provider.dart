import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import '../services/notification_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _service = StoryService();
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;
  static const String _lastStoryIdKey = 'last_story_id';

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotify();
  }

  Future<void> _checkForNewStories(List<Story> newStories) async {
    if (newStories.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final lastStoryId = prefs.getString(_lastStoryIdKey);
    final latestStory =
        newStories.first; // Assuming stories are ordered by date desc

    // Save the latest story ID
    await prefs.setString(_lastStoryIdKey, latestStory.id);

    // If we have a previous story ID and it's different from the latest
    // and there are new stories, show a notification
    if (lastStoryId != null && lastStoryId != latestStory.id) {
      await NotificationService.showStoryNotification();
    }
  }

  Future<void> fetchStories(String token) async {
    _setLoading(true);
    _error = null;
    try {
      final newStories = await _service.fetchStories(token);
      _stories = newStories;
      await _checkForNewStories(newStories);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStory(String token, String description, File photo) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.addStory(
        token: token,
        description: description,
        photo: photo,
      );
      await fetchStories(token);
    } catch (e) {
      _error = e.toString();
      _safeNotify(); 
    } finally {
      _setLoading(false);
    }
  }
}
