import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/design/design.dart';
import '../../core/providers/chat_provider.dart';
// ignore: unused_import
import '../../data/mock_service.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  List<Chat> _filteredChats(List<Chat> chats) {
    if (_searchQuery.isEmpty) return chats;
    final q = _searchQuery.toLowerCase();
    return chats.where((c) {
      final name = c.otherUser.fullName.toLowerCase();
      final username = c.otherUser.username.toLowerCase();
      final msg = c.lastMessage?.text.toLowerCase() ?? '';
      return name.contains(q) || username.contains(q) || msg.contains(q);
    }).toList();
  }

  void _showNewChatPicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewChatBottomSheet(
        onUserSelected: (user) async {
          Navigator.of(context).pop();
          final chat = await MockService.instance.startChat(user.id);
          ref.read(chatListProvider.notifier).load();
          if (mounted) {
            context.go('/chat/${chat.id}');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatListProvider);
    final chats = _filteredChats(chatState.chats);

    return Scaffold(
      backgroundColor: SeeUColors.background,
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton(
          onPressed: _showNewChatPicker,
          backgroundColor: SeeUColors.accent,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Сообщения',
                style: SeeUTypography.displayL,
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: SeeUColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(SeeURadii.pill),
                  boxShadow: SeeUShadows.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: SeeUTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    hintStyle: SeeUTypography.body.copyWith(
                      color: SeeUColors.textTertiary,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Icon(
                        PhosphorIconsRegular.magnifyingGlass,
                        color: SeeUColors.textTertiary,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                PhosphorIconsFill.xCircle,
                                color: SeeUColors.textTertiary,
                                size: 18,
                              ),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Chat list
            Expanded(
              child: chatState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SeeUColors.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : chats.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: SeeUColors.accent,
                          onRefresh: () =>
                              ref.read(chatListProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 100,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return _ChatTile(
                                chat: chats[index],
                                index: index,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.go('/chat/${chats[index].id}');
                                },
                                onDismissed: () {
                                  HapticFeedback.mediumImpact();
                                  // Remove chat locally for now
                                  ref
                                      .read(chatListProvider.notifier)
                                      .load();
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SeeUColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? PhosphorIconsRegular.magnifyingGlass
                    : PhosphorIconsRegular.chatCircleDots,
                size: 36,
                color: SeeUColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch ? 'Ничего не найдено' : 'Нет сообщений',
              style: SeeUTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Попробуйте другой запрос'
                  : 'Начните общение с друзьями.\nНажмите + чтобы написать первое сообщение!',
              textAlign: TextAlign.center,
              style: SeeUTypography.body.copyWith(
                color: SeeUColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              Tappable.scaled(
                onTap: _showNewChatPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: SeeUColors.accent,
                    borderRadius: BorderRadius.circular(SeeURadii.pill),
                  ),
                  child: Text(
                    'Начать общение',
                    style: SeeUTypography.subtitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat tile with swipe-to-delete
// ---------------------------------------------------------------------------

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _ChatTile({
    required this.chat,
    required this.index,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final user = chat.otherUser;
    final hasUnread = chat.unreadCount > 0;
    final lastMsg = chat.lastMessage;

    return Dismissible(
      key: ValueKey(chat.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: SeeUColors.error.withValues(alpha: 0.12),
        child: Icon(
          PhosphorIconsRegular.trash,
          color: SeeUColors.error,
          size: 24,
        ),
      ),
      child: Tappable.scaled(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300 + index * 50),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar with online dot
              _OnlineAvatar(
                avatarUrl: user.avatarUrl,
                isOnline: user.id.hashCode % 3 != 0,
                size: 52,
              ),
              const SizedBox(width: 14),
              // Name + last message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: SeeUTypography.subtitle.copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (lastMsg != null)
                          Text(
                            _formatTime(lastMsg.createdAt),
                            style: SeeUTypography.micro.copyWith(
                              color: hasUnread
                                  ? SeeUColors.accent
                                  : SeeUColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsg?.text ?? 'Начните общение',
                            style: SeeUTypography.caption.copyWith(
                              color: hasUnread
                                  ? SeeUColors.textPrimary
                                  : SeeUColors.textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SeeUColors.accent,
                              borderRadius:
                                  BorderRadius.circular(SeeURadii.pill),
                            ),
                            child: Text(
                              chat.unreadCount > 99
                                  ? '99+'
                                  : '${chat.unreadCount}',
                              style: SeeUTypography.micro.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'сейчас';
    if (diff.inHours < 24 && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timeago.format(dt, locale: 'ru');
  }
}

// ---------------------------------------------------------------------------
// Online avatar
// ---------------------------------------------------------------------------

class _OnlineAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isOnline;
  final double size;

  const _OnlineAvatar({
    this.avatarUrl,
    this.isOnline = false,
    this.size = 48,
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
              boxShadow: SeeUShadows.sm,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: SeeUColors.borderSubtle,
                      child: Icon(
                        PhosphorIconsRegular.user,
                        size: size * 0.45,
                        color: SeeUColors.textTertiary,
                      ),
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
              right: 1,
              bottom: 1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: SeeUColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SeeUColors.background,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New chat bottom sheet - user picker
// ---------------------------------------------------------------------------

class _NewChatBottomSheet extends StatefulWidget {
  final void Function(dynamic user) onUserSelected;

  const _NewChatBottomSheet({required this.onUserSelected});

  @override
  State<_NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<_NewChatBottomSheet> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    setState(() => _isLoading = true);
    final mock = MockService.instance;
    final users = await mock.getFollowing(mock.currentUser.username);
    if (mounted) {
      setState(() {
        _results = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadFollowing();
      return;
    }
    setState(() => _isLoading = true);
    final results = await MockService.instance.searchUsers(query);
    if (mounted) {
      setState(() {
        _results = results
            .where((u) => u.id != MockService.instance.currentUser.id)
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: SeeUColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SeeURadii.sheet),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SeeUColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Новое сообщение',
            style: SeeUTypography.title,
          ),
          const SizedBox(height: 16),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: SeeUColors.surfaceElevated,
                borderRadius: BorderRadius.circular(SeeURadii.pill),
                boxShadow: SeeUShadows.sm,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _search,
                style: SeeUTypography.body,
                decoration: InputDecoration(
                  hintText: 'Поиск пользователей...',
                  hintStyle: SeeUTypography.body.copyWith(
                    color: SeeUColors.textTertiary,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      color: SeeUColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SeeUColors.accent,
                      strokeWidth: 2,
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'Пользователи не найдены',
                          style: SeeUTypography.body.copyWith(
                            color: SeeUColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return Tappable.scaled(
                            onTap: () => widget.onUserSelected(user),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  _OnlineAvatar(
                                    avatarUrl: user.avatarUrl,
                                    isOnline:
                                        user.id.hashCode % 3 != 0,
                                    size: 44,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.fullName,
                                          style: SeeUTypography.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '@${user.username}',
                                          style:
                                              SeeUTypography.caption.copyWith(
                                            color: SeeUColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
