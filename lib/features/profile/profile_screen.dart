import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/story_provider.dart';
import '../feed/widgets/stories_row.dart';
import '../../core/models/user.dart';
import '../../core/models/post.dart';
import '../../core/models/highlight.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? username;

  const ProfileScreen({super.key, this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        final username = _resolveUsername();
        ref.read(userProfileProvider(username).notifier).loadSavedPosts();
      } else if (_tabController.index == 2) {
        final username = _resolveUsername();
        ref.read(userProfileProvider(username).notifier).loadTaggedPosts();
      }
      if (mounted) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _resolveUsername() {
    return widget.username ??
        ref.read(authProvider).user?.username ??
        'me_user';
  }

  @override
  Widget build(BuildContext context) {
    final username = _resolveUsername();
    final profileState = ref.watch(userProfileProvider(username));
    final authState = ref.watch(authProvider);
    final isOwnProfile = widget.username == null ||
        widget.username == authState.user?.username;

    if (profileState.isLoading && profileState.user == null) {
      return Scaffold(
        backgroundColor: SeeUColors.background,
        appBar: AppBar(
          backgroundColor: SeeUColors.background,
          elevation: 0,
          title: Text(username, style: SeeUTypography.subtitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: SeeUColors.accent),
        ),
      );
    }

    final user = profileState.user ?? User.demoMe;

    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        backgroundColor: SeeUColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: widget.username != null,
        leading: widget.username != null
            ? IconButton(
                icon: Icon(PhosphorIcons.arrowLeft(), size: 22, color: SeeUColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                user.username,
                style: SeeUTypography.subtitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              Icon(PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                  color: SeeUColors.accent, size: 18),
            ],
          ],
        ),
        actions: [
          if (isOwnProfile) ...[
            IconButton(
              icon: Icon(PhosphorIcons.plusSquare(), size: 24, color: SeeUColors.textPrimary),
              onPressed: () => _showCreateMenu(context),
            ),
            IconButton(
              icon: Icon(PhosphorIcons.list(), size: 24, color: SeeUColors.textPrimary),
              onPressed: () => _showSettingsSheet(context, authState),
            ),
          ] else ...[
            IconButton(
              icon: Icon(PhosphorIcons.dotsThreeVertical(), size: 24, color: SeeUColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _buildProfileHeader(
                context, user, isOwnProfile, profileState, ref),
          ),
        ],
        body: Column(
          children: [
            // Pill-style segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: SeeUColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(SeeURadii.small),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabPill(0, PhosphorIcons.squaresFour()),
                    _buildTabPill(1, PhosphorIcons.bookmarkSimple()),
                    _buildTabPill(2, PhosphorIcons.userCircle()),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PostsGrid(posts: profileState.posts),
                  isOwnProfile
                      ? _PostsGrid(posts: profileState.savedPosts)
                      : const _PrivateContent(),
                  _PostsGrid(posts: profileState.taggedPosts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(int index, IconData icon) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? SeeUColors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: isActive ? SeeUColors.accent : SeeUColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    User user,
    bool isOwnProfile,
    UserProfileState profileState,
    WidgetRef ref,
  ) {
    // Check if user has unseen stories
    final storyState = ref.watch(storyProvider);
    final userStoryGroup = storyState.storyGroups
        .where((g) => g.author.username == user.username)
        .toList();
    final hasStories = userStoryGroup.isNotEmpty;
    final hasUnseenStories = hasStories && !userStoryGroup.first.allSeen;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section: Avatar LEFT, Stats RIGHT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar — tappable if has stories
              GestureDetector(
                onTap: hasStories
                    ? () {
                        final groupIndex = storyState.storyGroups
                            .indexOf(userStoryGroup.first);
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (ctx, anim, secAnim) =>
                                StoryViewerRoute(
                              groups: storyState.storyGroups,
                              initialGroupIndex: groupIndex,
                            ),
                            transitionsBuilder: (ctx, anim, secAnim, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 200),
                          ),
                        );
                      }
                    : null,
                child: _buildAvatar(user, hasStories: hasStories, hasUnseenStories: hasUnseenStories),
              ),
              const SizedBox(width: 24),
              // Stats column
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(count: user.postsCount, label: 'ПУБЛИКАЦИИ'),
                    GestureDetector(
                      onTap: () => context
                          .push('/profile/${user.username}/followers'),
                      child: _StatItem(
                          count: user.followersCount, label: 'ПОДПИСЧИКИ'),
                    ),
                    GestureDetector(
                      onTap: () => context
                          .push('/profile/${user.username}/following'),
                      child: _StatItem(
                          count: user.followingCount, label: 'ПОДПИСКИ'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          Text(user.fullName, style: SeeUTypography.title),
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.bio!,
              style: SeeUTypography.body.copyWith(height: 1.5),
            ),
          ],
          // Website
          if (user.website != null && user.website!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.website!,
              style: SeeUTypography.body.copyWith(
                color: SeeUColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Action buttons
          if (isOwnProfile)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SeeUButton(
                    label: 'Редактировать',
                    variant: SeeUButtonVariant.secondary,
                    height: 42,
                    onTap: () => context.push('/profile/edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SeeUButton(
                    label: 'Поделиться',
                    variant: SeeUButtonVariant.secondary,
                    height: 42,
                    onTap: () {},
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: user.isFollowing
                      ? SeeUButton(
                          label: 'Отписаться',
                          variant: SeeUButtonVariant.secondary,
                          height: 42,
                          onTap: () => ref
                              .read(userProfileProvider(user.username).notifier)
                              .toggleFollow(),
                        )
                      : SeeUButton(
                          label: 'Подписаться',
                          variant: SeeUButtonVariant.primary,
                          height: 42,
                          onTap: () => ref
                              .read(userProfileProvider(user.username).notifier)
                              .toggleFollow(),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SeeUButton(
                    label: 'Сообщение',
                    variant: SeeUButtonVariant.secondary,
                    height: 42,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Highlights
          if (profileState.highlights.isNotEmpty)
            _HighlightsRow(highlights: profileState.highlights),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user, {bool hasStories = false, bool hasUnseenStories = false}) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnseenStories ? SeeUColors.storyGradient : null,
        border: hasUnseenStories
            ? null
            : Border.all(
                color: hasStories
                    ? SeeUColors.textTertiary.withValues(alpha: 0.3)
                    : SeeUColors.borderSubtle,
                width: hasStories ? 2 : 1,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SeeUColors.surfaceElevated,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: user.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: SeeUColors.borderSubtle),
                      errorWidget: (_, __, ___) => _avatarPlaceholder(user),
                    )
                  : _avatarPlaceholder(user),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(User user) {
    return Container(
      color: SeeUColors.textTertiary.withValues(alpha: 0.3),
      child: Center(
        child: Text(
          user.username[0].toUpperCase(),
          style: GoogleFonts.fraunces(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showSeeUBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Создать', style: SeeUTypography.title),
              ),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.image(), size: 22, color: SeeUColors.textPrimary),
              title: Text('Новый пост', style: SeeUTypography.body),
              onTap: () {
                Navigator.pop(context);
                context.push('/post/create');
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.clock(), size: 22, color: SeeUColors.accent),
              title: Text('Новая история', style: SeeUTypography.body),
              onTap: () {
                Navigator.pop(context);
                context.push('/story/create');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AuthState authState) {
    showSeeUBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Настройки', style: SeeUTypography.title),
              ),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.user(), size: 22, color: SeeUColors.textPrimary),
              title: Text('Редактировать профиль', style: SeeUTypography.body),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/edit');
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.signOut(), size: 22, color: SeeUColors.like),
              title: Text('Выйти',
                  style: SeeUTypography.body.copyWith(color: SeeUColors.like)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: SeeUTypography.displayL.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: SeeUTypography.micro.copyWith(fontSize: 9),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HighlightsRow extends StatelessWidget {
  final List<Highlight> highlights;

  const _HighlightsRow({required this.highlights});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final h = highlights[index];
              return Padding(
                padding: EdgeInsets.only(right: index < highlights.length - 1 ? 16 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SeeUColors.borderSubtle,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: h.coverUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: h.coverUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: SeeUColors.surfaceElevated,
                                child: Center(
                                  child: Icon(PhosphorIcons.image(),
                                      size: 28, color: SeeUColors.textTertiary),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      h.title,
                      style: SeeUTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostsGrid extends StatelessWidget {
  final List<Post> posts;

  const _PostsGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\u2022',
              style: GoogleFonts.fraunces(
                fontSize: 56,
                color: SeeUColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Пока нет постов',
              style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2, bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => context.push('/post/${post.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: post.media.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: post.media.first.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: SeeUColors.surfaceElevated),
                    errorWidget: (_, __, ___) =>
                        Container(color: SeeUColors.surfaceElevated),
                  )
                : Container(color: SeeUColors.surfaceElevated),
          ),
        );
      },
    );
  }
}

class _PrivateContent extends StatelessWidget {
  const _PrivateContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\u2013',
            style: GoogleFonts.fraunces(
              fontSize: 56,
              color: SeeUColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Подпишитесь, чтобы видеть посты',
            style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
