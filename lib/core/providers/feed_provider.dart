import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/post.dart';

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? nextCursor;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.nextCursor,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? nextCursor,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      nextCursor: nextCursor,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final ApiClient _apiClient;

  FeedNotifier(this._apiClient) : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.feed);
      final data = response.data as Map<String, dynamic>;
      final posts = (data['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      state = FeedState(
        posts: posts,
        isLoading: false,
        hasMore: data['has_more'] as bool? ?? false,
        nextCursor: data['next_cursor']?.toString(),
      );
    } on DioException catch (e) {
      // Fall back to demo data on network error
      state = FeedState(
        posts: Post.demoPosts,
        isLoading: false,
        error: apiErrorMessage(e),
        hasMore: false,
      );
    } catch (_) {
      state = FeedState(
        posts: Post.demoPosts,
        isLoading: false,
        hasMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await _apiClient.get(
        ApiEndpoints.feed,
        queryParameters: {'cursor': state.nextCursor},
      );
      final data = response.data as Map<String, dynamic>;
      final newPosts = (data['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: data['has_more'] as bool? ?? false,
        nextCursor: data['next_cursor']?.toString(),
      );
    } on DioException catch (_) {
      state = state.copyWith(isLoadingMore: false);
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

    final post = state.posts.firstWhere((p) => p.id == postId,
        orElse: () => state.posts.first);
    if (post.isLiked) {
      _apiClient.delete(ApiEndpoints.unlikePost(postId)).catchError((_) {
        _revertLike(postId);
        return Response(requestOptions: RequestOptions());
      });
    } else {
      _apiClient.post(ApiEndpoints.likePost(postId)).catchError((_) {
        _revertLike(postId);
        return Response(requestOptions: RequestOptions());
      });
    }
  }

  void _revertLike(String postId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      final newLiked = !p.isLiked;
      return p.copyWith(
        isLiked: newLiked,
        likesCount: newLiked ? p.likesCount + 1 : p.likesCount - 1,
      );
    }).toList();
    state = state.copyWith(posts: posts);
  }

  void toggleSave(String postId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(isSaved: !p.isSaved);
    }).toList();
    state = state.copyWith(posts: posts);
  }

  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedNotifier(apiClient);
});
