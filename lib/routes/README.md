# App Router with go_router

This directory contains the routing configuration for the app using Flutter's `go_router` package.

## Files

- `app_router.dart` - Main router configuration with go_router setup and custom page transitions

## Route Structure

```
/splash - Initial splash screen
/login - User login screen
/register - User registration screen
/home - Main home screen with story list
/add-story - Add new story screen
/story/:storyId - Story detail screen with story ID parameter
```

## Key Features

- Declarative route definitions
- Custom page transitions (fade and slide)
- Route parameters for dynamic content
- Type-safe navigation with named routes
