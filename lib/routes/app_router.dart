import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_story_screen.dart';
import '../screens/story_detail_screen.dart';
import '../models/story.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder:
            (context, state) =>
                fadeTransition(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) =>
                slideTransition(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) => slideTransition(
              key: state.pageKey,
              child: const RegisterScreen(),
            ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder:
            (context, state) =>
                fadeTransition(key: state.pageKey, child: const HomeScreen()),
      ),
      GoRoute(
        path: '/add-story',
        name: 'add-story',
        pageBuilder:
            (context, state) => slideTransition(
              key: state.pageKey,
              child: const AddStoryScreen(),
            ),
      ),
      GoRoute(
        path: '/story/:storyId',
        name: 'story-detail',
        pageBuilder: (context, state) {
          final story = state.extra as Story;
          return slideTransition(
            key: state.pageKey,
            child: StoryDetailScreen(story: story),
          );
        },
      ),
    ],
  );

  // Custom transition builders
  static CustomTransitionPage fadeTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage slideTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
