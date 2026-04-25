import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/design/design.dart';
import '../../core/providers/feed_provider.dart';
import '../../core/providers/notification_provider.dart';
import 'widgets/stories_row.dart';
import 'widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(feedProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final notifState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: SeeUColors.background,
      body: feedState.isLoading && feedState.posts.isEmpty
          ? _buildShimmer()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: SeeUColors.accent,
              child: feedState.posts.isEmpty
                  ? _buildEmpty()
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Custom header
                        SliverToBoxAdapter(
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'SeeU',
                                    style: SeeUTypography.displayL,
                                  ),
                                  const Spacer(),
                                  // Bell button
                                  _HeaderIconButton(
                                    icon: PhosphorIcon(PhosphorIcons.bell()),
                                    badge: notifState.unreadCount,
                                    onTap: () =>
                                        _showNotificationsSheet(context),
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: StoriesRow()),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == feedState.posts.length) {
                                return feedState.isLoadingMore
                                    ? _buildLoadingMore()
                                    : const SizedBox(height: 100);
                              }
                              return AnimationConfiguration
                                  .staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                delay: const Duration(milliseconds: 50),
                                child: SlideAnimation(
                                  verticalOffset: 30,
                                  curve: Curves.easeOutCubic,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOutCubic,
                                    child: PostCard(
                                        post: feedState.posts[index]),
                                  ),
                                ),
                              );
                            },
                            childCount: feedState.posts.length + 1,
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: _DotPulse(color: SeeUColors.accent),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SafeArea(
      child: SeeUShimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    ShimmerBox(width: 80, height: 32, radius: SeeURadii.small),
                    const Spacer(),
                    ShimmerBox(width: 40, height: 40, radius: SeeURadii.pill),
                    const SizedBox(width: 10),
                    ShimmerBox(width: 40, height: 40, radius: SeeURadii.pill),
                  ],
                ),
              ),
              // Stories shimmer
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 6,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShimmerBox(
                            width: 68, height: 68, radius: SeeURadii.pill),
                        const SizedBox(height: 5),
                        ShimmerBox(width: 52, height: 10, radius: 5),
                      ],
                    ),
                  ),
                ),
              ),
              // Post shimmer items
              ...List.generate(
                3,
                (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ShimmerBox(
                              width: 36, height: 36, radius: SeeURadii.pill),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(
                                  width: 120,
                                  height: 12,
                                  radius: SeeURadii.small),
                              const SizedBox(height: 4),
                              ShimmerBox(
                                  width: 80,
                                  height: 10,
                                  radius: SeeURadii.small),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ShimmerBox(
                          width: double.infinity,
                          height: 300,
                          radius: SeeURadii.card),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '0',
            style: GoogleFonts.fraunces(
              fontSize: 120,
              fontWeight: FontWeight.w300,
              color: SeeUColors.borderSubtle,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Пока нет постов',
            style: SeeUTypography.subtitle
                .copyWith(color: SeeUColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Подпишитесь на людей, чтобы видеть их посты',
            style: SeeUTypography.caption
                .copyWith(color: SeeUColors.textTertiary),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final notifState = ref.read(notificationProvider);
    ref.read(notificationProvider.notifier).markAllRead();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SeeUColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SeeURadii.sheet)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Уведомления',
                  style: SeeUTypography.title,
                ),
              ),
            ),
            Expanded(
              child: notifState.notifications.isEmpty
                  ? Center(
                      child: Text(
                        'Нет уведомлений',
                        style: SeeUTypography.caption,
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      itemCount: notifState.notifications.length,
                      itemBuilder: (_, i) {
                        final n = notifState.notifications[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: n.fromUser.avatarUrl != null
                                ? NetworkImage(n.fromUser.avatarUrl!)
                                : null,
                            backgroundColor: SeeUColors.surfaceElevated,
                            child: n.fromUser.avatarUrl == null
                                ? Text(
                                    n.fromUser.username[0].toUpperCase(),
                                    style: SeeUTypography.caption.copyWith(
                                        color: SeeUColors.textPrimary),
                                  )
                                : null,
                          ),
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${n.fromUser.username} ',
                                  style: SeeUTypography.caption
                                      .copyWith(fontWeight: FontWeight.w700, color: SeeUColors.textPrimary),
                                ),
                                TextSpan(
                                  text: n.message,
                                  style: SeeUTypography.caption
                                      .copyWith(color: SeeUColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          trailing: n.postThumbnailUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      SeeURadii.small),
                                  child: SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Image.network(
                                      n.postThumbnailUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : null,
                          dense: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header icon button ──────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final Widget icon;
  final int badge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: onTap,
      scaleFactor: 0.88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SeeUColors.surfaceElevated,
              borderRadius: BorderRadius.circular(SeeURadii.pill),
              boxShadow: SeeUShadows.sm,
            ),
            child: Center(
              child: IconTheme(
                data: const IconThemeData(
                    size: 20, color: SeeUColors.textPrimary),
                child: icon,
              ),
            ),
          ),
          if (badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: SeeUColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge > 9 ? '9+' : badge.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Dot pulse loading indicator ─────────────────────────────────────────

class _DotPulse extends StatefulWidget {
  final Color color;
  const _DotPulse({required this.color});

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final t = (_controller.value - delay) % 1.0;
          final scale = (t < 0.5) ? 0.6 + 0.4 * (t * 2) : 1.0 - 0.4 * ((t - 0.5) * 2);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6 * scale,
            height: 6 * scale,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.4 + 0.6 * scale),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
