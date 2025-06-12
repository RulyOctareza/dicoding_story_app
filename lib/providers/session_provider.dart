import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/story_service.dart';

class SessionProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  final StoryService _storyService = StoryService();

  SessionProvider() {
    developer.log('SessionProvider initialized', name: 'SessionProvider');
    _loadToken();
  }

  Future<void> _loadToken() async {
    developer.log(
      'Loading token from SharedPreferences',
      name: 'SessionProvider',
    );
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    developer.log('Loaded token: $_token', name: 'SessionProvider');
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    developer.log(
      'Attempting login for email: $email',
      name: 'SessionProvider',
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _storyService.login(
        email: email,
        password: password,
      );
      final loginResult = result['loginResult'];
      _token = loginResult['token'];
      developer.log(
        'Login successful, token received: $_token',
        name: 'SessionProvider',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      developer.log(
        'Token saved to SharedPreferences',
        name: 'SessionProvider',
      );

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          developer.log('Navigating to home screen', name: 'SessionProvider');
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    } catch (e) {
      developer.log('Login failed: $e', name: 'SessionProvider', error: e);
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _storyService.register(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToLogin(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Register success')),
        );
      });
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void goToRegister(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  Future<void> logout(BuildContext context) async {
    developer.log('Logging out...', name: 'SessionProvider');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    developer.log('Token cleared', name: 'SessionProvider');
    notifyListeners();

    if (context.mounted) {
      developer.log('Navigating to login screen', name: 'SessionProvider');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
