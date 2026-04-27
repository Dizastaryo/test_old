import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/design/design.dart';
import '../../../core/providers/story_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/story.dart';
import 'story_circle.dart';

class StoriesRow extends ConsumerWidget {
  const StoriesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyState = ref.watch(storyProvider);
    final authState = ref.watch(authProvider);
    final me = authState.user;

    if (storyState.isLoading) {
      return _buildShimmer();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: storyState.storyGroups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: StoryCircle(
                imageUrl: me?.avatarUrl,
                username: 'Ваша история',
                isOwn: true,
                onTap: () => context.push('/story/create'),
              ),
            );
          }
          final group = storyState.storyGroups[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: StoryCircle(
              imageUrl: group.author.avatarUrl,
              username: group.author.username,
              isSeen: group.allSeen,
              onTap: () => _openStoryViewer(
                  context, storyState.storyGroups, index - 1),
            ),
          );
        },
      ),
    );
  }

  void _openStoryViewer(
      BuildContext context, List<StoryGroup> groups, int groupIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoryViewerRoute(groups: groups, initialGroupIndex: groupIndex),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 100,
      child: SeeUShimmer(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(width: 68, height: 68, radius: SeeURadii.pill),
                  const SizedBox(height: 5),
                  ShimmerBox(width: 52, height: 10, radius: 5),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Inline story viewer route wrapper
class StoryViewerRoute extends StatelessWidget {
  final List<StoryGroup> groups;
  final int initialGroupIndex;

  const StoryViewerRoute({
    super.key,
    required this.groups,
    required this.initialGroupIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _InlineStoryViewer(
      groups: groups,
      initialGroupIndex: initialGroupIndex,
    );
  }
}

class _InlineStoryViewer extends StatefulWidget {
  final List<StoryGroup> groups;
  final int initialGroupIndex;

  const _InlineStoryViewer({
    required this.groups,
    required this.initialGroupIndex,
  });

  @override
  State<_InlineStoryViewer> createState() => _InlineStoryViewerState();
}

class _InlineStoryViewerState extends State<_InlineStoryViewer>
    with SingleTickerProviderStateMixin {
  late int _groupIndex;
  late int _storyIndex;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroupIndex;
    _storyIndex = 0;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  StoryGroup get _currentGroup => widget.groups[_groupIndex];
  Story get _currentStory => _currentGroup.stories[_storyIndex];

  void _nextStory() {
    _progressController.reset();
    if (_storyIndex < _currentGroup.stories.length - 1) {
      setState(() => _storyIndex++);
      _progressController.forward();
    } else if (_groupIndex < widget.groups.length - 1) {
      setState(() {
        _groupIndex++;
        _storyIndex = 0;
      });
      _progressController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    _progressController.reset();
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
    } else if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _storyIndex = widget.groups[_groupIndex].stories.length - 1;
      });
    }
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final story = _currentStory;
    final group = _currentGroup;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          _progressController.stop();
        },
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) {
          _progressController.stop();
        },
        onLongPressEnd: (_) {
          _progressController.forward();
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 200) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story image
            CachedNetworkImage(
              imageUrl: story.mediaUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                ),
              ),
            ),

            // Top gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Progress bars
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: List.generate(group.stories.length, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : 1.5,
                          right: i == group.stories.length - 1 ? 0 : 1.5,
                        ),
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.5),
                          child: i < _storyIndex
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                )
                              : i == _storyIndex
                                  ? AnimatedBuilder(
                                      animation: _progressController,
                                      builder: (_, __) => Stack(
                                        children: [
                                          Container(
                                              color: Colors.white
                                                  .withValues(alpha: 0.35)),
                                          FractionallySizedBox(
                                            widthFactor:
                                                _progressController.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(1.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                        borderRadius:
                                            BorderRadius.circular(1.5),
                                      ),
                                    ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            ),

            // User info header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28, left: 12, right: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: group.author.avatarUrl != null
                            ? NetworkImage(group.author.avatarUrl!)
                            : null,
                        backgroundColor: Colors.grey,
                        child: group.author.avatarUrl == null
                            ? Text(
                                group.author.username[0].toUpperCase(),
                                style: SeeUTypography.caption
                                    .copyWith(color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                group.author.username,
                                style: SeeUTypography.subtitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _timeAgo(story.createdAt),
                              style: SeeUTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: PhosphorIcon(PhosphorIcons.x(),
                            color: Colors.white, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Text overlay
            if (story.textOverlay != null && story.textOverlay!.isNotEmpty)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(SeeURadii.small),
                  ),
                  child: Text(
                    story.textOverlay!,
                    style: SeeUTypography.title.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Reply bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                            borderRadius:
                                BorderRadius.circular(SeeURadii.pill),
                          ),
                          child: Center(
                            child: Text(
                              'Отправить сообщение...',
                              style: SeeUTypography.body.copyWith(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // Like story
                        },
                        child: Icon(
                          PhosphorIcons.heart(),
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
