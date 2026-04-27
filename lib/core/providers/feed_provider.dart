import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../../data/mock_service.dart';

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int _page;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    int page = 0,
  }) : _page = page;

  int get page => _page;

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? page,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      page: page ?? _page,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await MockService.instance.getFeed();
      state = FeedState(
        posts: posts,
        isLoading: false,
        hasMore: posts.length >= 10,
        page: 1,
      );
    } catch (e) {
      state = FeedState(
        posts: Post.demoPosts,
        isLoading: false,
        error: e.toString(),
        hasMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newPosts = await MockService.instance.getFeed(page: state.page);
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: newPosts.length >= 10,
        page: state.page + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => loadFeed();

  void toggleLike(String postId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      final newLiked = !p.isLiked;
      return p.copyWith(
        isLiked: newLiked,
        likesCount: newLiked ? p.likesCount + 1 : p.likesCount - 1,
      );
    }).toList();
    state = state.copyWith(posts: posts);
    MockService.instance.toggleLike(postId);
  }

  void toggleSave(String postId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(isSaved: !p.isSaved);
    }).toList();
    state = state.copyWith(posts: posts);
    MockService.instance.toggleSave(postId);
  }

  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
