# Migration to go_router

## Overview

This document summarizes the migration from Flutter's traditional navigation system to `go_router` for the Dicoding Story App.

## Changes Made

### 1. Router Configuration (`lib/routes/app_router.dart`)

- **Before**: Used `onGenerateRoute` with traditional `Navigator` and custom `PageRoute` classes
- **After**: Configured `GoRouter` with declarative route definitions
- **Key changes**:
  - Replaced `onGenerateRoute` method with `GoRouter` configuration
  - Moved custom page transitions to inline `CustomTransitionPage` builders
  - Added route names for easier navigation
  - Added support for route parameters (e.g., `:storyId`)

### 2. Main App Configuration (`lib/main.dart`)

- **Before**: Used `MaterialApp` with `navigatorKey` and `onGenerateRoute`
- **After**: Used `MaterialApp.router` with `routerConfig`
- **Key changes**:
  - Replaced `MaterialApp` with `MaterialApp.router`
  - Removed `navigatorKey`, `onGenerateRoute`, and `initialRoute`
  - Added `routerConfig: AppRouter.router`

### 3. Navigation Calls Throughout the App

#### Splash Screen (`lib/screens/splash_screen.dart`)

- **Before**: `Navigator.of(context).pushReplacementNamed('/home')`
- **After**: `context.goNamed('home')`

#### Session Provider (`lib/providers/session_provider.dart`)

- **Before**: `Navigator.of(context).pushReplacementNamed('/login')`
- **After**: `context.goNamed('login')`
- **Before**: `Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false)`
- **After**: `context.goNamed('login')`

#### Home Screen (`lib/screens/home_screen.dart`)

- **Before**: `Navigator.push(context, MaterialPageRoute(...))`
- **After**: `context.goNamed('add-story')` and `context.goNamed('story-detail', ...)`

#### Add Story Screen (`lib/screens/add_story_screen.dart`)

- **Before**: `Navigator.of(context).pop()`
- **After**: `context.pop()`

### 4. Route Structure

The new route structure is flat instead of nested:

```
/splash
/login
/register
/home
/add-story
/story/:storyId
```

### 5. Route Parameters and Data Passing

- Story detail navigation now uses path parameters (`:storyId`) and `extra` data
- Example: `context.goNamed('story-detail', pathParameters: {'storyId': story.id}, extra: story)`

## Benefits of go_router

1. **Declarative routing**: Routes are defined in one place, making navigation structure clear
2. **Type safety**: Route names and parameters are more explicit
3. **Better deep linking**: Improved support for web URLs and deep links
4. **Easier testing**: Routes can be tested more easily
5. **Modern Flutter**: Aligns with Flutter's current navigation recommendations

## Files Modified

1. `lib/routes/app_router.dart` - Complete rewrite for go_router
2. `lib/main.dart` - Updated to use MaterialApp.router
3. `lib/screens/splash_screen.dart` - Updated navigation calls
4. `lib/providers/session_provider.dart` - Updated navigation calls
5. `lib/screens/home_screen.dart` - Updated navigation calls
6. `lib/screens/add_story_screen.dart` - Updated navigation calls

## Files Removed

- `lib/routes/page_transitions.dart` - No longer needed (transitions moved inline)

## Testing

- ✅ Flutter analyze passes without issues
- ✅ Debug build compiles successfully
- ✅ All navigation patterns converted to go_router equivalents

## Next Steps

1. Test the app thoroughly on different platforms
2. Verify deep linking functionality
3. Test back button behavior
4. Consider adding route guards for authentication if needed
