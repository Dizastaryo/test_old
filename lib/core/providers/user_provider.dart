import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/highlight.dart';

class UserProfileState {
  final User? user;
  final List<Post> posts;
  final List<Post> savedPosts;
  final List<Post> taggedPosts;
  final List<Highlight> highlights;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.user,
    this.posts = const [],
    this.savedPosts = const [],
    this.taggedPosts = const [],
    this.highlights = const [],
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    User? user,
    List<Post>? posts,
    List<Post>? savedPosts,
    List<Post>? taggedPosts,
    List<Highlight>? highlights,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      savedPosts: savedPosts ?? this.savedPosts,
      taggedPosts: taggedPosts ?? this.taggedPosts,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final ApiClient _apiClient;
  final String username;

  UserProfileNotifier(this._apiClient, this.username)
      : super(const UserProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final responses = await Future.wait([
        _apiClient.get(ApiEndpoints.userProfile(username)),
        _apiClient.get(ApiEndpoints.userPosts(username)),
        _apiClient.get(ApiEndpoints.userHighlights(username)),
      ]);

      final user = User.fromJson(responses[0].data as Map<String, dynamic>);
      final postsData = responses[1].data as Map<String, dynamic>;
      final posts = (postsData['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      final highlightsData = responses[2].data as List?;
      final highlights = highlightsData
              ?.map((e) => Highlight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      state = UserProfileState(
        user: user,
        posts: posts,
        highlights: highlights,
      );
    } on DioException catch (e) {
      // Demo fallback
      final demoUser = User.demoUsers.isNotEmpty
          ? User.demoUsers.firstWhere(
              (u) => u.username == username,
              orElse: () => User.demoMe,
            )
          : User.demoMe;
      state = UserProfileState(
        user: demoUser,
        posts: Post.demoPosts.where((p) => p.author.username == username).toList(),
        highlights: Highlight.demoHighlights(demoUser),
        error: apiErrorMessage(e),
      );
    } catch (_) {
      final demoUser = User.demoMe;
      state = UserProfileState(
        user: demoUser,
        posts: Post.demoPosts,
        highlights: Highlight.demoHighlights(demoUser),
      );
    }
  }

  Future<void> loadSavedPosts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userSavedPosts(username));
      final data = response.data as Map<String, dynamic>;
      final posts = (data['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(savedPosts: posts);
    } on DioException catch (_) {
      state = state.copyWith(savedPosts: []);
    }
  }

  Future<void> loadTaggedPosts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userTaggedPosts(username));
      final data = response.data as Map<String, dynamic>;
      final posts = (data['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(taggedPosts: posts);
    } on DioException catch (_) {
      state = state.copyWith(taggedPosts: []);
    }
  }

  Future<void> toggleFollow() async {
    final user = state.user;
    if (user == null) return;

    final wasFollowing = user.isFollowing;
    state = state.copyWith(
      user: user.copyWith(
        isFollowing: !wasFollowing,
        followersCount: wasFollowing
            ? user.followersCount - 1
            : user.followersCount + 1,
      ),
    );

    try {
      if (wasFollowing) {
        await _apiClient.delete(ApiEndpoints.unfollowUser(username));
      } else {
        await _apiClient.post(ApiEndpoints.followUser(username));
      }
    } on DioException catch (_) {
      // Revert on error
      state = state.copyWith(user: user);
    }
  }
}

final userProfileProvider = StateNotifierProvider.family<
    UserProfileNotifier, UserProfileState, String>((ref, username) {
  final apiClient = ref.watch(apiClientProvider);
  return UserProfileNotifier(apiClient, username);
});

// Search provider
class SearchState {
  final List<User> users;
  final List<Post> posts;
  final bool isLoading;
  final String query;

  const SearchState({
    this.users = const [],
    this.posts = const [],
    this.isLoading = false,
    this.query = '',
  });
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiClient _apiClient;

  SearchNotifier(this._apiClient) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = SearchState(query: query, isLoading: true);
    try {
      final responses = await Future.wait([
        _apiClient.get(ApiEndpoints.searchUsers(query)),
        _apiClient.get(ApiEndpoints.searchPosts(query)),
      ]);

      final users = (responses[0].data['data'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
      final posts = (responses[1].data['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();

      state = SearchState(users: users, posts: posts, query: query);
    } on DioException catch (_) {
      // Demo search
      final lq = query.toLowerCase();
      final demoUsers = User.demoUsers
          .where((u) =>
              u.username.toLowerCase().contains(lq) ||
              u.fullName.toLowerCase().contains(lq))
          .toList();
      final demoPosts = Post.demoPosts
          .where((p) =>
              p.caption?.toLowerCase().contains(lq) == true ||
              p.author.username.toLowerCase().contains(lq))
          .toList();
      state = SearchState(users: demoUsers, posts: demoPosts, query: query);
    } catch (_) {
      state = SearchState(query: query);
    }
  }

  void clear() => state = const SearchState();
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(apiClientProvider));
});

// Explore grid posts provider
final explorePostsProvider = FutureProvider<List<Post>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(ApiEndpoints.explore);
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return Post.demoPosts;
  }
});
