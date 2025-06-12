import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/story.dart';
import '../services/story_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _service = StoryService();
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

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

  Future<void> fetchStories(String token) async {
    _setLoading(true);
    _error = null;
    try {
      _stories = await _service.fetchStories(token);
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
      _safeNotify(); // Notify untuk menampilkan error
    } finally {
      _setLoading(false);
    }
  }
}
