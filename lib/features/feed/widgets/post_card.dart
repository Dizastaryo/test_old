import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/design/design.dart';
import '../../../core/models/post.dart';
import '../../../core/providers/feed_provider.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final bool isDetail;

  const PostCard({super.key, required this.post, this.isDetail = false});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScaleAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
    ]).animate(_heartAnimController);
    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _showHeart = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!widget.post.isLiked) {
      _likePost();
    }
    HapticFeedback.mediumImpact();
    setState(() => _showHeart = true);
    _heartAnimController.forward(from: 0);
  }

  void _likePost() {
    HapticFeedback.lightImpact();
    ref.read(feedProvider.notifier).toggleLike(widget.post.id);
  }

  void _savePost() {
    HapticFeedback.lightImpact();
    ref.read(feedProvider.notifier).toggleSave(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, post),
          const SizedBox(height: 10),
          _buildMedia(context, post),
          const SizedBox(height: 12),
          _buildActions(context, post),
          _buildLikesRow(context, post),
          _buildCaption(context, post),
          _buildCommentsPreview(context, post),
          _buildTimeRow(context, post),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Post post) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/${post.author.username}'),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: post.author.avatarUrl != null
                  ? CachedNetworkImageProvider(post.author.avatarUrl!)
                  : null,
              backgroundColor: SeeUColors.surfaceElevated,
              child: post.author.avatarUrl == null
                  ? Icon(PhosphorIcons.user(),
                      color: SeeUColors.textTertiary, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/profile/${post.author.username}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.author.username,
                          style: SeeUTypography.subtitle
                              .copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.author.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                            color: SeeUColors.accent, size: 16),
                      ],
                    ],
                  ),
                  if (post.location != null && post.location!.isNotEmpty)
                    Text(
                      post.location!,
                      style: SeeUTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showPostOptions(context, post),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(PhosphorIcons.dotsThreeOutline(),
                  size: 20, color: SeeUColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, Post post) {
    if (post.media.isEmpty) return const SizedBox.shrink();
    final media = post.media.first;
    final aspectRatio = media.aspectRatio ?? 1.0;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SeeURadii.card),
          boxShadow: SeeUShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: media.url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: SeeUColors.surfaceElevated,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: SeeUColors.surfaceElevated,
                  child: Icon(PhosphorIcons.imageSquare(),
                      color: SeeUColors.textTertiary, size: 48),
                ),
              ),
              // Double-tap heart animation
              if (_showHeart)
                Center(
                  child: AnimatedBuilder(
                    animation: _heartScaleAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _heartScaleAnim.value * 80,
                      child: Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        color: SeeUColors.accent,
                        size: 1,
                      ),
                    ),
                  ),
                ),
              // Multiple images indicator
              if (post.media.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(SeeURadii.pill),
                    ),
                    child: Icon(
                      PhosphorIcons.squaresFour(),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Post post) {
    return Row(
      children: [
        _ActionButton(
          icon: PhosphorIcon(post.isLiked
              ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
              : PhosphorIcons.heart()),
          color: post.isLiked ? SeeUColors.like : SeeUColors.textPrimary,
          onTap: _likePost,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: PhosphorIcon(PhosphorIcons.chatCircle()),
          onTap: () => context.push('/post/${post.id}/comments'),
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: PhosphorIcon(PhosphorIcons.shareFat()),
          onTap: () {},
        ),
        const Spacer(),
        _ActionButton(
          icon: PhosphorIcon(post.isSaved
              ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill)
              : PhosphorIcons.bookmarkSimple()),
          onTap: _savePost,
        ),
      ],
    );
  }

  Widget _buildLikesRow(BuildContext context, Post post) {
    if (post.likesCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        post.likedByUsername != null
            ? 'Нравится ${post.likedByUsername} и ещё ${_formatCount(post.likesCount - 1)}'
            : '${_formatCount(post.likesCount)} отметок «Нравится»',
        style:
            SeeUTypography.caption.copyWith(fontWeight: FontWeight.w700, color: SeeUColors.textPrimary),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildCaption(BuildContext context, Post post) {
    if (post.caption == null || post.caption!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: _ExpandableCaption(
        postId: post.id,
        username: post.author.username,
        caption: post.caption!,
      ),
    );
  }

  Widget _buildCommentsPreview(BuildContext context, Post post) {
    if (post.commentsCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () => context.push('/post/${post.id}/comments'),
        child: SeeUChip(
          label: '${_formatCount(post.commentsCount)} комментариев',
          bgColor: SeeUColors.accentSoft,
          fgColor: SeeUColors.accent,
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, Post post) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        timeago.format(post.createdAt, allowFromNow: true).toUpperCase(),
        style: SeeUTypography.micro,
      ),
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SeeUColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SeeURadii.sheet)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: SeeUColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.shareFat(),
                  color: SeeUColors.textPrimary),
              title: Text('Поделиться', style: SeeUTypography.body),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.bookmarkSimple(),
                  color: SeeUColors.textPrimary),
              title: Text('Сохранить', style: SeeUTypography.body),
              onTap: () {
                _savePost();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Icon(PhosphorIcons.flag(), color: SeeUColors.like),
              title: Text('Пожаловаться',
                  style: SeeUTypography.body
                      .copyWith(color: SeeUColors.like)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

// ─── Action button ───────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: onTap,
      scaleFactor: 0.90,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: SeeUColors.surfaceElevated,
          borderRadius: BorderRadius.circular(SeeURadii.small),
          boxShadow: SeeUShadows.sm,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: 22,
              color: color ?? SeeUColors.textPrimary,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

// ─── Expandable caption ──────────────────────────────────────────────────

class _ExpandableCaption extends StatefulWidget {
  final String postId;
  final String username;
  final String caption;

  const _ExpandableCaption({
    required this.postId,
    required this.username,
    required this.caption,
  });

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  final bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const maxLength = 100;
    final isLong = widget.caption.length > maxLength;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.username} ',
            style: SeeUTypography.body
                .copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: _expanded || !isLong
                ? widget.caption
                : '${widget.caption.substring(0, maxLength)}...',
            style: SeeUTypography.body,
          ),
          if (isLong && !_expanded)
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push('/post/${widget.postId}'),
                child: Text(
                  ' ещё',
                  style: SeeUTypography.body
                      .copyWith(color: SeeUColors.textTertiary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
