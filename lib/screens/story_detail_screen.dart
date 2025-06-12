import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/session_provider.dart';
import '../providers/story_detail_provider.dart';
import '../utils/date_time_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/state_widgets.dart';
import '../widgets/network_image.dart';

class StoryDetailScreen extends StatelessWidget {
  final Story story;
  const StoryDetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    return ChangeNotifierProvider(
      create:
          (_) =>
              StoryDetailProvider()
                ..fetchDetail(sessionProvider.token!, story.id),
      child: Consumer<StoryDetailProvider>(
        builder: (context, detailProvider, _) {
          if (detailProvider.isLoading) {
            return const Scaffold(body: LoadingState());
          } else if (detailProvider.error != null) {
            return Scaffold(
              appBar: const CustomAppBar(title: ''),
              body: ErrorState(
                message: detailProvider.error!,
                onRetry:
                    () => detailProvider.fetchDetail(
                      sessionProvider.token!,
                      story.id,
                    ),
              ),
            );
          } else if (detailProvider.story != null) {
            final detail = detailProvider.story!;
            return Scaffold(
              appBar: CustomAppBar(title: detail.name),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: NetworkImageWithLoader(
                        imageUrl: detail.photoUrl,
                        width: 250,
                        height: 250,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Posted by ${detail.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTimeUtils.getRelativeTime(detail.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      detail.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(body: ErrorState(message: 'Story not found'));
          }
        },
      ),
    );
  }
}
