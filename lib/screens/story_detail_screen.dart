import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/session_provider.dart';
import '../providers/story_detail_provider.dart';

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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (detailProvider.error != null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(detailProvider.error!)),
            );
          } else if (detailProvider.story != null) {
            final detail = detailProvider.story!;
            return Scaffold(
              appBar: AppBar(title: Text(detail.name)),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          detail.photoUrl,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      detail.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created at: ${detail.createdAt}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(body: Center(child: Text('No data')));
          }
        },
      ),
    );
  }
}
