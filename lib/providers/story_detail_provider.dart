import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_service.dart';

class StoryDetailProvider extends ChangeNotifier {
  final StoryService _service = StoryService();
  Story? _story;
  bool _isLoading = false;
  String? _error;

  Story? get story => _story;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDetail(String token, String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _story = await _service.fetchStoryDetail(token, id);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
