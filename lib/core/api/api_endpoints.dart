class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = 'http://192.168.8.88:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String checkUsername = '/auth/check-username';

  // Feed
  static const String feed = '/feed';
  static const String feedCursor = '/feed?cursor=';

  // Posts
  static const String posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static String likePost(String id) => '/posts/$id/like';
  static String unlikePost(String id) => '/posts/$id/unlike';
  static String savePost(String id) => '/posts/$id/save';
  static String unsavePost(String id) => '/posts/$id/unsave';
  static String postComments(String id) => '/posts/$id/comments';
  static String commentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';
  static String likeComment(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/like';
  static String commentReplies(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/replies';

  // Stories
  static const String stories = '/stories';
  static String storyById(String id) => '/stories/$id';
  static String viewStory(String id) => '/stories/$id/view';
  static String userStories(String username) => '/users/$username/stories';

  // Users
  static const String users = '/users';
  static const String me = '/users/me';
  static String userProfile(String username) => '/users/$username';
  static String userPosts(String username) => '/users/$username/posts';
  static String userSavedPosts(String username) => '/users/$username/saved';
  static String userTaggedPosts(String username) => '/users/$username/tagged';
  static String userHighlights(String username) => '/users/$username/highlights';
  static String followUser(String username) => '/users/$username/follow';
  static String unfollowUser(String username) => '/users/$username/unfollow';
  static String userFollowers(String username) => '/users/$username/followers';
  static String userFollowing(String username) => '/users/$username/following';
  static String editProfile = '/users/me';

  // Explore
  static const String explore = '/explore';
  static const String search = '/search';
  static String searchQuery(String q) => '/search?q=$q';
  static String searchUsers(String q) => '/search/users?q=$q';
  static String searchPosts(String q) => '/search/posts?q=$q';

  // Notifications
  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static String markRead(String id) => '/notifications/$id/read';

  // Upload
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';
}
