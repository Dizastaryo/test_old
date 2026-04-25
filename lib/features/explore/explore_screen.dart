import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
    _debounce = Timer(const Duration(milliseconds: 500), () {
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
            // Sticky search bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              height: 56,
              decoration: BoxDecoration(
                color: SeeUColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                boxShadow: SeeUShadows.sm,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(PhosphorIcons.magnifyingGlass(),
                      size: 20, color: SeeUColors.textTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      onTap: () {},
                      style: SeeUTypography.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Поиск',
                        hintStyle: SeeUTypography.body.copyWith(
                          color: SeeUColors.textTertiary,
                        ),
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
                        child: Icon(PhosphorIcons.x(),
                            size: 18, color: SeeUColors.textSecondary),
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

  Widget _buildSearchResults(dynamic searchState) {
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
            Text(
              '?',
              style: GoogleFonts.fraunces(
                fontSize: 64,
                color: SeeUColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Нет результатов по запросу «${_searchCtrl.text}»',
              style: SeeUTypography.body.copyWith(color: SeeUColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (searchState.users.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Люди', style: SeeUTypography.title),
          ),
          ...searchState.users.map((user) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () => context.push('/profile/${user.username}'),
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
                          radius: 28,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          backgroundColor:
                              SeeUColors.textTertiary.withValues(alpha: 0.3),
                          child: user.avatarUrl == null
                              ? Text(
                                  user.username[0].toUpperCase(),
                                  style: SeeUTypography.title
                                      .copyWith(color: Colors.white),
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
                                        PhosphorIcons.sealCheck(
                                            PhosphorIconsStyle.fill),
                                        color: SeeUColors.accent,
                                        size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.fullName,
                                style: SeeUTypography.body
                                    .copyWith(color: SeeUColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildFollowPill(user.isFollowing),
                      ],
                    ),
                  ),
                ),
              )),
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
    );
  }

  Widget _buildFollowPill(bool isFollowing) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isFollowing ? SeeUColors.surfaceElevated : SeeUColors.accent,
        borderRadius: BorderRadius.circular(SeeURadii.pill),
        border: isFollowing
            ? Border.all(color: SeeUColors.borderSubtle, width: 1)
            : null,
      ),
      child: Center(
        child: Text(
          isFollowing ? 'Отписаться' : 'Подписаться',
          style: SeeUTypography.caption.copyWith(
            color: isFollowing ? SeeUColors.textPrimary : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildExploreGrid() {
    final postsAsync = ref.watch(explorePostsProvider);

    return postsAsync.when(
      loading: () => _buildGridShimmer(),
      error: (_, __) => _buildGridWithData(
        List.generate(
          20,
          (i) => 'https://picsum.photos/seed/explore$i/300/300',
        ),
      ),
      data: (posts) => _buildGridWithData(
        posts.map((p) => p.media.isNotEmpty ? p.media.first.url : '').toList(),
        posts: posts.map((p) => p.id).toList(),
      ),
    );
  }

  Widget _buildGridWithData(List<String> urls,
      {List<String>? posts}) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final url = urls[index];
                final postId = posts?[index];
                return GestureDetector(
                  onTap: postId != null
                      ? () => context.push('/post/$postId')
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: url.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: SeeUColors.surfaceElevated),
                            errorWidget: (_, __, ___) => Container(
                                color: SeeUColors.surfaceElevated),
                          )
                        : Container(color: SeeUColors.surfaceElevated),
                  ),
                );
              },
              childCount: urls.length,
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
    return GridView.builder(
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
