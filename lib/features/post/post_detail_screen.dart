import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/models/post.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../feed/widgets/post_card.dart';
import 'comments_screen.dart';

final _postDetailProvider = FutureProvider.family<Post, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiEndpoints.postById(id));
    return Post.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return Post.demoPosts.firstWhere(
      (p) => p.id == id,
      orElse: () => Post.demoPosts.first,
    );
  }
});

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(_postDetailProvider(postId));

    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        backgroundColor: SeeUColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Пост', style: SeeUTypography.subtitle),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), size: 22, color: SeeUColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: postAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SeeUColors.accent),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.warning(), size: 48, color: SeeUColors.textTertiary),
              const SizedBox(height: 16),
              Text('Не удалось загрузить пост',
                  style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary)),
              const SizedBox(height: 16),
              SeeUButton(
                label: 'Повторить',
                variant: SeeUButtonVariant.primary,
                width: 120,
                height: 44,
                onTap: () => ref.refresh(_postDetailProvider(postId)),
              ),
            ],
          ),
        ),
        data: (post) => ListView(
          children: [
            PostCard(post: post, isDetail: true),
            const Divider(height: 1, color: SeeUColors.borderSubtle),
            CommentsSection(postId: postId),
          ],
        ),
      ),
    );
  }
}
