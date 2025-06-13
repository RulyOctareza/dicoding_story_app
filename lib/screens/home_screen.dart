import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../providers/session_provider.dart';
import '../providers/story_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_time_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/state_widgets.dart';
import '../widgets/network_image.dart';
import '../widgets/premium_features.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    developer.log('HomeScreen initialized', name: 'HomeScreen');
    
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      if (sessionProvider.token != null) {
        developer.log('Fetching stories...', name: 'HomeScreen');
        storyProvider.fetchStories(sessionProvider.token!).then((_) {
          _animationController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreStories();
    }
  }

  Future<void> _loadMoreStories() async {
    if (_isLoadingMore) return;

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    
    if (sessionProvider.token != null && storyProvider.hasMoreData) {
      setState(() {
        _isLoadingMore = true;
      });

      await storyProvider.loadMoreStories(sessionProvider.token!);

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
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
          
          const FlavorBadge(),
          const SizedBox(width: 8),
          
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
          
          IconButton(
            icon: Icon(
              notificationProvider.isEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: () async {
              try {
                await notificationProvider.toggleNotifications();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        notificationProvider.isEnabled
                            ? 'Notifications enabled'
                            : 'Notifications disabled',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip:
                notificationProvider.isEnabled
                    ? 'Disable Notifications'
                    : 'Enable Notifications',
          ),
          
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
            _animationController.reset();
            _animationController.forward();
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildBody(storyProvider, loc),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton(
          onPressed: () {
            context.goNamed('home-add-story');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(StoryProvider storyProvider, AppLocalizations loc) {
    if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
      return const LoadingState();
    }

    if (storyProvider.error != null && storyProvider.stories.isEmpty) {
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
      controller: _scrollController,
      itemCount: storyProvider.stories.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        
        if (index == storyProvider.stories.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final story = storyProvider.stories[index];
        return _buildStoryCard(story, index);
      },
    );
  }

  Widget _buildStoryCard(story, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  context.goNamed(
                    'home-story-detail',
                    pathParameters: {'storyId': story.id},
                    extra: story,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      
                      Hero(
                        tag: 'story-${story.id}',
                        child: ClipOval(
                          child: NetworkImageWithLoader(
                            imageUrl: story.photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateTimeUtils.getRelativeTime(story.createdAt, context),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                if (story.lat != null && story.lon != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.blue[500],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
