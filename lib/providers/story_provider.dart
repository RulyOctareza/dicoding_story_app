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
  
  // NEW: Pagination properties
  int _currentPage = 1;
  bool _hasMoreData = true;
  static const int _pageSize = 10;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

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
    _currentPage = 1; // Reset pagination
    _hasMoreData = true;
    try {
      final newStories = await _service.fetchStories(token, page: _currentPage, size: _pageSize);
      _stories = newStories;
      await _checkForNewStories(newStories);
      
      // Check if we have more data
      if (newStories.length < _pageSize) {
        _hasMoreData = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Load more stories for pagination
  Future<void> loadMoreStories(String token) async {
    if (!_hasMoreData || _isLoading) return;
    
    try {
      _currentPage++;
      final newStories = await _service.fetchStories(token, page: _currentPage, size: _pageSize);
      
      if (newStories.isNotEmpty) {
        _stories.addAll(newStories);
        if (newStories.length < _pageSize) {
          _hasMoreData = false;
        }
      } else {
        _hasMoreData = false;
      }
      
      _safeNotify();
    } catch (e) {
      _error = e.toString();
      _currentPage--; // Revert page increment on error
      _safeNotify();
    }
  }

  Future<void> addStory(String token, String description, File photo, {double? lat, double? lon}) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.addStory(
        token: token,
        description: description,
        photo: photo,
        lat: lat,
        lon: lon,
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
