import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/story.dart';

class StoryState {
  final List<StoryGroup> storyGroups;
  final bool isLoading;
  final String? error;

  const StoryState({
    this.storyGroups = const [],
    this.isLoading = false,
    this.error,
  });

  StoryState copyWith({
    List<StoryGroup>? storyGroups,
    bool? isLoading,
    String? error,
  }) {
    return StoryState(
      storyGroups: storyGroups ?? this.storyGroups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StoryNotifier extends StateNotifier<StoryState> {
  final ApiClient _apiClient;

  StoryNotifier(this._apiClient) : super(const StoryState()) {
    loadStories();
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.stories);
      final data = response.data as Map<String, dynamic>;
      final groups = (data['data'] as List)
          .map((e) => StoryGroup.fromJson(e as Map<String, dynamic>))
          .toList();
      state = StoryState(storyGroups: groups);
    } on DioException catch (e) {
      state = StoryState(
        storyGroups: StoryGroup.demoStoryGroups,
        error: apiErrorMessage(e),
      );
    } catch (_) {
      state = StoryState(storyGroups: StoryGroup.demoStoryGroups);
    }
  }

  Future<void> markSeen(String storyId) async {
    final updatedGroups = state.storyGroups.map((group) {
      final updatedStories = group.stories.map((story) {
        if (story.id == storyId) return story.copyWith(isSeen: true);
        return story;
      }).toList();
      return StoryGroup(
        author: group.author,
        stories: updatedStories,
        allSeen: updatedStories.every((s) => s.isSeen),
      );
    }).toList();

    state = state.copyWith(storyGroups: updatedGroups);

    try {
      await _apiClient.post(ApiEndpoints.viewStory(storyId));
    } catch (_) {}
  }
}

final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier(ref.watch(apiClientProvider));
});
