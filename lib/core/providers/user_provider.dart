import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/highlight.dart';
import '../../data/mock_service.dart';

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
  final String username;

  UserProfileNotifier(this.username) : super(const UserProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final mock = MockService.instance;
      final user = await mock.getProfile(username);
      final posts = await mock.getUserPosts(username);
      final highlights = await mock.getUserHighlights(username);

      state = UserProfileState(
        user: user,
        posts: posts,
        highlights: highlights,
      );
    } catch (e) {
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
        error: e.toString(),
      );
    }
  }

  Future<void> loadSavedPosts() async {
    try {
      final posts = await MockService.instance.getUserSavedPosts();
      state = state.copyWith(savedPosts: posts);
    } catch (_) {
      state = state.copyWith(savedPosts: []);
    }
  }

  Future<void> loadTaggedPosts() async {
    try {
      final posts = await MockService.instance.getUserTaggedPosts(username);
      state = state.copyWith(taggedPosts: posts);
    } catch (_) {
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
      await MockService.instance.toggleFollow(username);
    } catch (_) {
      // Revert on error
      state = state.copyWith(user: user);
    }
  }
}

final userProfileProvider = StateNotifierProvider.family<
    UserProfileNotifier, UserProfileState, String>((ref, username) {
  return UserProfileNotifier(username);
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
  SearchNotifier() : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = SearchState(query: query, isLoading: true);
    try {
      final mock = MockService.instance;
      final users = await mock.searchUsers(query);
      final posts = await mock.searchPosts(query);
      state = SearchState(users: users, posts: posts, query: query);
    } catch (_) {
      state = SearchState(query: query);
    }
  }

  void clear() => state = const SearchState();
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

// Explore grid posts provider
final explorePostsProvider = FutureProvider<List<Post>>((ref) async {
  try {
    return await MockService.instance.getExplorePosts();
  } catch (_) {
    return Post.demoPosts;
  }
});
