import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/design/design.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/mock_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late AnimationController _sendBtnController;
  late Animation<double> _sendBtnScale;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sendBtnScale = CurvedAnimation(
      parent: _sendBtnController,
      curve: Curves.elasticOut,
    );
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendBtnController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendBtnController.forward();
      } else {
        _sendBtnController.reverse();
      }
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final pos = _scrollController.position.maxScrollExtent;
        if (animate) {
          _scrollController.animateTo(
            pos,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(pos);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _textController.clear();

    await ref.read(chatMessagesProvider(widget.chatId).notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final msgState = ref.watch(chatMessagesProvider(widget.chatId));
    final chats = ref.watch(chatListProvider).chats;
    final chat = chats.where((c) => c.id == widget.chatId).isNotEmpty
        ? chats.firstWhere((c) => c.id == widget.chatId)
        : null;
    final currentUser = ref.watch(authProvider).user;
    final myId = currentUser?.id ?? 'me';
    final otherUser = chat?.otherUser;
    final isOnline = otherUser != null && otherUser.id.hashCode % 3 != 0;

    // Scroll to bottom when messages load
    if (msgState.messages.isNotEmpty) {
      _scrollToBottom(animate: false);
    }

    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: SeeUColors.background,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Back button
                  Tappable.scaled(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.go('/chat');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        PhosphorIconsRegular.caretLeft,
                        color: SeeUColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  // Avatar
                  if (otherUser != null) ...[
                    _SmallAvatar(
                      avatarUrl: otherUser.avatarUrl,
                      isOnline: isOnline,
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Name & status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser?.fullName ?? 'Чат',
                          style: SeeUTypography.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isOnline)
                          Text(
                            'в сети',
                            style: SeeUTypography.micro.copyWith(
                              color: SeeUColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (otherUser != null)
                          Text(
                            'не в сети',
                            style: SeeUTypography.micro,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: msgState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SeeUColors.accent,
                      strokeWidth: 2.5,
                    ),
                  )
                : msgState.messages.isEmpty
                    ? _buildEmptyChat(otherUser)
                    : _buildMessageList(msgState.messages, myId),
          ),
          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(dynamic otherUser) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (otherUser != null) ...[
              _SmallAvatar(
                avatarUrl: otherUser.avatarUrl,
                isOnline: false,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                otherUser.fullName,
                style: SeeUTypography.title,
              ),
              const SizedBox(height: 4),
              Text(
                '@${otherUser.username}',
                style: SeeUTypography.caption,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Начните диалог',
              style: SeeUTypography.body.copyWith(
                color: SeeUColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages, String myId) {
    // Group by day
    final groups = <String, List<ChatMessage>>{};
    for (final msg in messages) {
      final key = _dateKey(msg.createdAt);
      groups.putIfAbsent(key, () => []).add(msg);
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      // Date separator
      widgets.add(_DateSeparator(label: _formatDateLabel(entry.value.first.createdAt)));
      for (var i = 0; i < entry.value.length; i++) {
        final msg = entry.value[i];
        final isMine = msg.senderId == myId;
        final showTail = i == entry.value.length - 1 ||
            entry.value[i + 1].senderId != msg.senderId;
        widgets.add(
          _MessageBubble(
            message: msg,
            isMine: isMine,
            showTail: showTail,
          ),
        );
      }
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      physics: const BouncingScrollPhysics(),
      children: widgets,
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: SeeUColors.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: SeeUColors.background,
                    borderRadius: BorderRadius.circular(SeeURadii.pill),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: SeeUTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      hintStyle: SeeUTypography.body.copyWith(
                        color: SeeUColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              ScaleTransition(
                scale: _sendBtnScale,
                child: Tappable.scaled(
                  onTap: _hasText ? _sendMessage : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _hasText ? SeeUColors.accent : SeeUColors.borderSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsFill.paperPlaneRight,
                      color: _hasText ? Colors.white : SeeUColors.textTertiary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    if (diff < 7) {
      const days = [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
      ];
      return days[dt.weekday - 1];
    }
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Date separator
// ---------------------------------------------------------------------------

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: SeeUColors.borderSubtle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: SeeUTypography.micro.copyWith(
                color: SeeUColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: SeeUColors.borderSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showTail;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        top: showTail ? 6 : 2,
        bottom: 0,
        left: isMine ? 48 : 0,
        right: isMine ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            // Time on the left
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 2),
              child: Text(
                time,
                style: SeeUTypography.micro.copyWith(
                  fontSize: 10,
                  color: SeeUColors.textTertiary,
                ),
              ),
            ),
          ],
          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? SeeUColors.accent : SeeUColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(
                    !isMine && showTail ? 4 : 16,
                  ),
                  bottomRight: Radius.circular(
                    isMine && showTail ? 4 : 16,
                  ),
                ),
                boxShadow: isMine ? null : SeeUShadows.sm,
              ),
              child: Text(
                message.text,
                style: SeeUTypography.body.copyWith(
                  color: isMine ? Colors.white : SeeUColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isMine) ...[
            // Time on the right
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: Text(
                time,
                style: SeeUTypography.micro.copyWith(
                  fontSize: 10,
                  color: SeeUColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small avatar for app bar
// ---------------------------------------------------------------------------

class _SmallAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isOnline;
  final double size;

  const _SmallAvatar({
    this.avatarUrl,
    this.isOnline = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SeeUColors.surfaceElevated,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: SeeUColors.borderSubtle,
                    ),
                    errorWidget: (_, __, ___) => Icon(
                      PhosphorIconsRegular.user,
                      size: size * 0.45,
                      color: SeeUColors.textTertiary,
                    ),
                  )
                : Icon(
                    PhosphorIconsRegular.user,
                    size: size * 0.45,
                    color: SeeUColors.textTertiary,
                  ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: SeeUColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SeeUColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
