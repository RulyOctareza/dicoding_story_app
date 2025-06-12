import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/session_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    developer.log('SplashScreen initialized', name: 'SplashScreen');

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Setup fade animation
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animation and check session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log(
        'Starting animation and session check',
        name: 'SplashScreen',
      );
      _controller.forward();
      _checkSession();
    });
  }

  @override
  void dispose() {
    developer.log('SplashScreen disposed', name: 'SplashScreen');
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    developer.log('Checking session...', name: 'SplashScreen');
    developer.log(
      'Current token: ${sessionProvider.token}',
      name: 'SplashScreen',
    );

    try {
      // Wait for both animation and delay
      await Future.wait([
        Future.delayed(const Duration(seconds: 3)),
        _controller.forward().orCancel,
      ]);

      if (!mounted) return;

      if (sessionProvider.token != null) {
        developer.log('Token found, navigating to home', name: 'SplashScreen');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        developer.log(
          'No token found, navigating to login',
          name: 'SplashScreen',
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      developer.log(
        'Animation or session check error: $e',
        name: 'SplashScreen',
        error: e,
      );
      // Handle any animation cancellation gracefully
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building SplashScreen', name: 'SplashScreen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Story App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
