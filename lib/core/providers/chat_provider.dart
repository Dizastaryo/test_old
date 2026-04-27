import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_service.dart';

class ChatListState {
  final List<Chat> chats;
  final bool isLoading;
  const ChatListState({this.chats = const [], this.isLoading = false});
  ChatListState copyWith({List<Chat>? chats, bool? isLoading}) => ChatListState(chats: chats ?? this.chats, isLoading: isLoading ?? this.isLoading);
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier() : super(const ChatListState()) { load(); }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final chats = await MockService.instance.getChats();
    state = ChatListState(chats: chats);
  }
}

class ChatMessagesState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final Chat? chat;
  const ChatMessagesState({this.messages = const [], this.isLoading = false, this.chat});
  ChatMessagesState copyWith({List<ChatMessage>? messages, bool? isLoading, Chat? chat}) => ChatMessagesState(messages: messages ?? this.messages, isLoading: isLoading ?? this.isLoading, chat: chat ?? this.chat);
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final String chatId;
  ChatMessagesNotifier(this.chatId) : super(const ChatMessagesState()) { load(); }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final messages = await MockService.instance.getChatMessages(chatId);
    state = ChatMessagesState(messages: messages);
  }

  Future<void> sendMessage(String text) async {
    final message = await MockService.instance.sendMessage(chatId, text);
    state = state.copyWith(messages: [...state.messages, message]);
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, ChatListState>((ref) => ChatListNotifier());
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>((ref, chatId) => ChatMessagesNotifier(chatId));
