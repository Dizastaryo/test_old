import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/design/design.dart';
import '../../core/providers/user_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(searchProvider.notifier).clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchProvider.notifier).search(value.trim());
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(searchProvider.notifier).clear();
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final hasQuery = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: SeeUColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.fromLTRB(16, 12, 16, _isFocused ? 4 : 8),
              height: 52,
              decoration: BoxDecoration(
                color: SeeUColors.surfaceElevated,
                borderRadius: BorderRadius.circular(SeeURadii.pill),
                boxShadow: _isFocused ? SeeUShadows.md : SeeUShadows.sm,
                border: _isFocused
                    ? Border.all(color: SeeUColors.accentSoft, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Icon(PhosphorIcons.magnifyingGlass(),
                      size: 20,
                      color: _isFocused
                          ? SeeUColors.accent
                          : SeeUColors.textTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: SeeUTypography.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Поиск людей и публикаций',
                        hintStyle: SeeUTypography.body
                            .copyWith(color: SeeUColors.textTertiary),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (hasQuery)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: SeeUColors.textTertiary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(PhosphorIcons.x(),
                              size: 14, color: SeeUColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: hasQuery
                  ? _buildSearchResults(searchState)
                  : _buildExploreGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: SeeUColors.accent),
      );
    }

    if (searchState.users.isEmpty && searchState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.magnifyingGlass(),
                size: 56, color: SeeUColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: SeeUTypography.title,
            ),
            const SizedBox(height: 6),
            Text(
              'Попробуйте другой запрос',
              style: SeeUTypography.body
                  .copyWith(color: SeeUColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (searchState.users.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Люди', style: SeeUTypography.title),
            ),
            ...List.generate(searchState.users.length, (index) {
              final user = searchState.users[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: _UserSearchCard(user: user),
                    ),
                  ),
                ),
              );
            }),
          ],
          if (searchState.posts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Публикации', style: SeeUTypography.title),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: searchState.posts.length,
              itemBuilder: (context, index) {
                final post = searchState.posts[index];
                return GestureDetector(
                  onTap: () => context.push('/post/${post.id}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExploreGrid() {
    final postsAsync = ref.watch(explorePostsProvider);

    return postsAsync.when(
      loading: () => _buildGridShimmer(),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.warning(), size: 48, color: SeeUColors.textTertiary),
            const SizedBox(height: 12),
            Text('Не удалось загрузить', style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary)),
          ],
        ),
      ),
      data: (posts) => _buildMasonryGrid(posts),
    );
  }

  Widget _buildMasonryGrid(List<dynamic> posts) {
    // Create a masonry-like pattern: alternate between large and small tiles
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= posts.length) return null;
                final post = posts[index];
                final isLarge = index % 7 == 0; // Every 7th is large
                final url = post.media.isNotEmpty ? post.media.first.url : '';

                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: 3,
                  duration: const Duration(milliseconds: 300),
                  child: ScaleAnimation(
                    scale: 0.95,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () => context.push('/post/${post.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isLarge ? 16 : 8),
                            boxShadow: isLarge ? SeeUShadows.sm : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              url.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: url,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: SeeUColors.surfaceElevated),
                                      errorWidget: (_, __, ___) =>
                                          Container(color: SeeUColors.surfaceElevated),
                                    )
                                  : Container(color: SeeUColors.surfaceElevated),
                              // Multi-image indicator
                              if (post.media.length > 1)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Icon(
                                    PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
                                    color: Colors.white,
                                    size: 16,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
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
              childCount: posts.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: (MediaQuery.of(context).size.width - 16) / 3,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildGridShimmer() {
    final itemSize = (MediaQuery.of(context).size.width - 16) / 3;
    return SeeUShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          mainAxisExtent: itemSize,
        ),
        itemCount: 18,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: SeeUColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}


class _UserSearchCard extends StatelessWidget {
  final dynamic user;

  const _UserSearchCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: () => context.push('/profile/${user.username}'),
      scaleFactor: 0.97,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SeeUColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: SeeUShadows.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: user.avatarUrl != null
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : null,
              backgroundColor: SeeUColors.textTertiary.withValues(alpha: 0.3),
              child: user.avatarUrl == null
                  ? Text(
                      user.username[0].toUpperCase(),
                      style:
                          SeeUTypography.title.copyWith(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          style: SeeUTypography.subtitle
                              .copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                            PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                            color: SeeUColors.accent,
                            size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.fullName,
                    style: SeeUTypography.caption
                        .copyWith(color: SeeUColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
