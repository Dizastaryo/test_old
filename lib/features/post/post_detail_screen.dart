import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/models/post.dart';
import '../../data/mock_service.dart';
import '../feed/widgets/post_card.dart';
import 'comments_screen.dart';

final _postDetailProvider = FutureProvider.family<Post, String>((ref, id) async {
  return MockService.instance.getPost(id);
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
