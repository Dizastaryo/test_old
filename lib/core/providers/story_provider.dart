import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../../data/mock_service.dart';

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
  StoryNotifier() : super(const StoryState()) {
    loadStories();
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final groups = await MockService.instance.getStories();
      state = StoryState(storyGroups: groups);
    } catch (e) {
      state = StoryState(
        storyGroups: StoryGroup.demoStoryGroups,
        error: e.toString(),
      );
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
    await MockService.instance.markStorySeen(storyId);
  }
}

final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier();
});
