import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/session_provider.dart';
import '../providers/story_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_time_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/state_widgets.dart';
import './story_detail_screen.dart';
import './add_story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('HomeScreen initialized', name: 'HomeScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      if (sessionProvider.token != null) {
        developer.log('Fetching stories...', name: 'HomeScreen');
        storyProvider.fetchStories(sessionProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final storyProvider = Provider.of<StoryProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: loc.translate('stories'),
        actions: [
          // Language Switch
          Row(
            children: [
              Text(localeProvider.isIndonesian ? 'ID' : 'EN'),
              Switch(
                value: localeProvider.isIndonesian,
                onChanged: (value) async {
                  await localeProvider.setLocale(value ? 'id' : 'en');
                  developer.log(
                    'Switched language to: ${value ? 'ID' : 'EN'}',
                    name: 'HomeScreen',
                  );
                },
              ),
            ],
          ),
          // Notification Toggle
          IconButton(
            icon: Icon(
              notificationProvider.isEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: () {
              notificationProvider.toggleNotifications();
            },
            tooltip:
                notificationProvider.isEnabled
                    ? 'Disable Notifications'
                    : 'Enable Notifications',
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => sessionProvider.logout(context),
            tooltip: loc.translate('logout'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (sessionProvider.token != null) {
            await storyProvider.fetchStories(sessionProvider.token!);
          }
        },
        child: _buildBody(storyProvider, loc),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStoryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(StoryProvider storyProvider, AppLocalizations loc) {
    if (storyProvider.isLoading) {
      return const LoadingState();
    }

    if (storyProvider.error != null) {
      return ErrorState(
        message: storyProvider.error!,
        onRetry: () {
          final sessionProvider = Provider.of<SessionProvider>(
            context,
            listen: false,
          );
          if (sessionProvider.token != null) {
            storyProvider.fetchStories(sessionProvider.token!);
          }
        },
      );
    }

    if (storyProvider.stories.isEmpty) {
      return EmptyState(message: loc.translate('no_data'));
    }

    return ListView.builder(
      itemCount: storyProvider.stories.length,
      itemBuilder: (context, index) {
        final story = storyProvider.stories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(story.photoUrl),
              radius: 30,
            ),
            title: Text(story.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateTimeUtils.getRelativeTime(story.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDetailScreen(story: story),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
