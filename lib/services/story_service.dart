import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class StoryService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<List<Story>> fetchStories(String token) async {
    developer.log('Fetching stories...', name: 'StoryService');
    final response = await http.get(
      Uri.parse('$baseUrl/stories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    developer.log(
      'Stories API response status: ${response.statusCode}',
      name: 'StoryService',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List stories = data['listStory'];
      developer.log('Fetched ${stories.length} stories', name: 'StoryService');
      return stories.map((e) => Story.fromJson(e)).toList();
    } else {
      final error = 'Failed to load stories: ${response.body}';
      developer.log(error, name: 'StoryService', error: Exception(error));
      throw Exception(error);
    }
  }

  Future<void> addStory({
    required String token,
    required String description,
    required File photo,
  }) async {
    developer.log('Uploading new story...', name: 'StoryService');
    final uri = Uri.parse('$baseUrl/stories');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['description'] = description
          ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

    developer.log('Sending story upload request...', name: 'StoryService');
    final response = await request.send();
    developer.log(
      'Story upload response status: ${response.statusCode}',
      name: 'StoryService',
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      final error = 'Failed to upload story: $respStr';
      developer.log(error, name: 'StoryService', error: Exception(error));
      throw Exception(error);
    }
    developer.log('Story uploaded successfully', name: 'StoryService');
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Register failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Story> fetchStoryDetail(String token, String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      return Story.fromJson(data['story']);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch story detail');
    }
  }
}
