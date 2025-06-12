import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import 'page_transitions.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return FadePageRoute(page: const SplashScreen());
      case '/login':
        return SlidePageRoute(page: const LoginScreen());
      case '/register':
        return SlidePageRoute(page: const RegisterScreen());
      case '/home':
        return FadePageRoute(page: const HomeScreen());
      case '/':
      default:
        return FadePageRoute(page: const SplashScreen());
    }
  }
}
