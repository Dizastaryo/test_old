import 'dart:math';

import '../core/models/user.dart';
import '../core/models/post.dart';
import '../core/models/story.dart';
import '../core/models/comment.dart';
import '../core/models/notification.dart';
import '../core/models/highlight.dart';

// ---------------------------------------------------------------------------
// Chat models (inline)
// ---------------------------------------------------------------------------

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Chat {
  final String id;
  final User otherUser;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  Chat copyWith({
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id,
      otherUser: otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ---------------------------------------------------------------------------
// MockService
// ---------------------------------------------------------------------------

class MockService {
  // Singleton
  static final MockService instance = MockService._();
  MockService._() {
    _init();
  }

  final Random _rng = Random();

  // ---- State containers ----
  late User _currentUser;
  bool _isAuthenticated = false;

  final List<User> _users = [];
  final List<Post> _posts = [];
  final List<Story> _stories = [];
  final List<Comment> _comments = [];
  final List<AppNotification> _notifications = [];
  final List<Highlight> _highlights = [];
  final List<Chat> _chats = [];
  final List<ChatMessage> _chatMessages = [];

  // Saved post IDs by current user
  final Set<String> _savedPostIds = {};

  // Following set: username of users that current user follows
  final Set<String> _followingUsernames = {};

  int _nextId = 10000;
  String _genId() => '${_nextId++}';

  // ---- Simulated delay ----
  Future<void> _delay() =>
      Future.delayed(Duration(milliseconds: 200 + _rng.nextInt(300)));

  // =========================================================================
  // INIT - populate all mock data
  // =========================================================================

  void _init() {
    final now = DateTime.now();

    // ------ Users ------
    _currentUser = User(
      id: 'me',
      username: 'aidana_k',
      fullName: 'Айдана Касымова',
      bio: 'UI/UX дизайнер из Алматы',
      website: 'https://aidana.design',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      postsCount: 28,
      followersCount: 1240,
      followingCount: 435,
      isFollowing: false,
      isPrivate: false,
      isVerified: false,
      createdAt: DateTime(2023, 3, 12),
    );
    _isAuthenticated = true;

    final otherUsers = <User>[
      User(
        id: 'u1',
        username: 'timur_dev',
        fullName: 'Тимур Алиев',
        bio: 'Flutter-разработчик. Open source.',
        website: 'https://github.com/timur',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        postsCount: 95,
        followersCount: 12400,
        followingCount: 320,
        isFollowing: false,
        isPrivate: false,
        isVerified: true,
        createdAt: DateTime(2021, 5, 1),
      ),
      User(
        id: 'u2',
        username: 'diana_photo',
        fullName: 'Диана Нурланова',
        bio: 'Фотограф | Путешествия | Портреты',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        postsCount: 213,
        followersCount: 34500,
        followingCount: 180,
        isFollowing: false,
        isPrivate: false,
        isVerified: true,
        createdAt: DateTime(2020, 11, 20),
      ),
      User(
        id: 'u3',
        username: 'arman_fit',
        fullName: 'Арман Сериков',
        bio: 'Фитнес-тренер. Здоровый образ жизни.',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        postsCount: 178,
        followersCount: 8900,
        followingCount: 410,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2022, 1, 10),
      ),
      User(
        id: 'u4',
        username: 'madina_art',
        fullName: 'Мадина Бекмуратова',
        bio: 'Художница. Акварель и масло.',
        website: 'https://madina-art.kz',
        avatarUrl: 'https://i.pravatar.cc/150?img=9',
        postsCount: 67,
        followersCount: 5600,
        followingCount: 290,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2022, 8, 5),
      ),
      User(
        id: 'u5',
        username: 'nursultan_travel',
        fullName: 'Нурсултан Жанибеков',
        bio: 'Путешественник. 45 стран.',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        postsCount: 312,
        followersCount: 52000,
        followingCount: 150,
        isFollowing: false,
        isPrivate: false,
        isVerified: true,
        createdAt: DateTime(2019, 7, 15),
      ),
      User(
        id: 'u6',
        username: 'aliya_cook',
        fullName: 'Алия Омарова',
        bio: 'Домашняя кухня. Рецепты каждый день.',
        avatarUrl: 'https://i.pravatar.cc/150?img=16',
        postsCount: 145,
        followersCount: 19800,
        followingCount: 340,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2021, 9, 3),
      ),
      User(
        id: 'u7',
        username: 'damir_music',
        fullName: 'Дамир Касенов',
        bio: 'Музыкант. Гитара и вокал.',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        postsCount: 54,
        followersCount: 3200,
        followingCount: 560,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2023, 2, 14),
      ),
      User(
        id: 'u8',
        username: 'zarina_style',
        fullName: 'Зарина Ташкенбаева',
        bio: 'Fashion blogger | Стиль и мода',
        website: 'https://zarina.style',
        avatarUrl: 'https://i.pravatar.cc/150?img=20',
        postsCount: 198,
        followersCount: 41000,
        followingCount: 220,
        isFollowing: false,
        isPrivate: false,
        isVerified: true,
        createdAt: DateTime(2020, 4, 18),
      ),
      User(
        id: 'u9',
        username: 'ruslan_tech',
        fullName: 'Руслан Ибрагимов',
        bio: 'Tech reviewer. Гаджеты и новинки.',
        avatarUrl: 'https://i.pravatar.cc/150?img=14',
        postsCount: 89,
        followersCount: 15600,
        followingCount: 310,
        isFollowing: false,
        isPrivate: true,
        isVerified: false,
        createdAt: DateTime(2022, 6, 22),
      ),
      User(
        id: 'u10',
        username: 'kamila_yoga',
        fullName: 'Камила Рахимова',
        bio: 'Йога-инструктор. Гармония тела и души.',
        avatarUrl: 'https://i.pravatar.cc/150?img=25',
        postsCount: 120,
        followersCount: 7800,
        followingCount: 450,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2022, 3, 8),
      ),
      User(
        id: 'u11',
        username: 'bekzat_auto',
        fullName: 'Бекзат Муратов',
        bio: 'Автомобили и скорость',
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        postsCount: 76,
        followersCount: 4500,
        followingCount: 280,
        isFollowing: false,
        isPrivate: true,
        isVerified: false,
        createdAt: DateTime(2023, 1, 5),
      ),
      User(
        id: 'u12',
        username: 'ainur_books',
        fullName: 'Айнур Сагинтаева',
        bio: 'Книжный блогер. 100+ книг в год.',
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
        postsCount: 230,
        followersCount: 11200,
        followingCount: 190,
        isFollowing: false,
        isPrivate: false,
        isVerified: false,
        createdAt: DateTime(2021, 12, 1),
      ),
    ];

    _users.clear();
    _users.add(_currentUser);
    _users.addAll(otherUsers);

    // Mark some as followed by current user
    _followingUsernames.addAll([
      'timur_dev',
      'diana_photo',
      'arman_fit',
      'aliya_cook',
      'zarina_style',
      'kamila_yoga',
    ]);

    // Update isFollowing flags in the list
    for (var i = 0; i < _users.length; i++) {
      if (_followingUsernames.contains(_users[i].username)) {
        _users[i] = _users[i].copyWith(isFollowing: true);
      }
    }

    // ------ Posts (25+) ------
    _posts.clear();

    User userByIdx(int idx) => otherUsers[idx % otherUsers.length];

    _posts.addAll([
      Post(
        id: 'p1',
        author: userByIdx(1), // diana_photo
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p1/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Закат над Алматы. Каждый вечер - как картина #sunset #almaty #photography',
        location: 'Алматы, Казахстан',
        likesCount: 2341,
        commentsCount: 87,
        isLiked: true,
        isSaved: false,
        likedByUsername: 'timur_dev',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Post(
        id: 'p2',
        author: userByIdx(0), // timur_dev
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p2/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Новый проект на Flutter уже в продакшене! 6 месяцев работы, и вот результат. #flutter #dart #mobile',
        likesCount: 1890,
        commentsCount: 134,
        isLiked: false,
        isSaved: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'p3',
        author: userByIdx(2), // arman_fit
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p3/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Утренняя тренировка - лучший способ начать день! Кто со мной? #fitness #gym #motivation',
        location: 'Алматы, Казахстан',
        likesCount: 956,
        commentsCount: 42,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'kamila_yoga',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Post(
        id: 'p4',
        author: userByIdx(3), // madina_art
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p4a/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p4b/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p4c/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Новая серия акварелей. Вдохновение - горы Тянь-Шаня #art #watercolor #mountains',
        location: 'Алматы, Казахстан',
        likesCount: 1567,
        commentsCount: 63,
        isLiked: true,
        isSaved: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'p5',
        author: userByIdx(4), // nursultan_travel
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p5/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
        ],
        caption: 'Чарынский каньон - младший брат Гранд Каньона. Невероятная красота! #charyn #kazakhstan #travel',
        location: 'Чарынский каньон',
        likesCount: 4521,
        commentsCount: 198,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'diana_photo',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: 'p6',
        author: userByIdx(5), // aliya_cook
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p6/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Бешбармак по маминому рецепту. Сохраняйте! #food #kazakh #recipe #homecooking',
        location: 'Астана, Казахстан',
        likesCount: 3210,
        commentsCount: 156,
        isLiked: true,
        isSaved: true,
        likedByUsername: 'zarina_style',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'p7',
        author: userByIdx(6), // damir_music
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p7/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Акустический вечер в Barley. Спасибо всем, кто пришел! #music #acoustic #live',
        location: 'Алматы, Казахстан',
        likesCount: 678,
        commentsCount: 34,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'p8',
        author: userByIdx(7), // zarina_style
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p8a/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p8b/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Осенний лук: оверсайз пальто + ботинки. Как вам? #fashion #style #autumn #ootd',
        location: 'Алматы, Казахстан',
        likesCount: 5670,
        commentsCount: 234,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'ainur_books',
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      Post(
        id: 'p9',
        author: userByIdx(8), // ruslan_tech
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p9/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Обзор нового MacBook Pro M4. Стоит ли обновляться? Полный обзор на канале. #tech #apple #review',
        likesCount: 2340,
        commentsCount: 189,
        isLiked: true,
        isSaved: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Post(
        id: 'p10',
        author: userByIdx(9), // kamila_yoga
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p10/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Утренняя практика на рассвете. Начните день с благодарности. #yoga #morning #mindfulness',
        location: 'Бурабай, Казахстан',
        likesCount: 1123,
        commentsCount: 56,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'arman_fit',
        createdAt: now.subtract(const Duration(hours: 14)),
      ),
      Post(
        id: 'p11',
        author: userByIdx(1), // diana_photo
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p11a/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p11b/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p11c/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p11d/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Портретная серия "Лица города". Проект, над которым работала 3 месяца. #portrait #photography #faces',
        location: 'Алматы, Казахстан',
        likesCount: 6780,
        commentsCount: 312,
        isLiked: true,
        isSaved: true,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      Post(
        id: 'p12',
        author: _currentUser,
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p12/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Рабочее место мечты. Минимализм и функциональность. #workspace #design #minimal',
        location: 'Алматы, Казахстан',
        likesCount: 345,
        commentsCount: 23,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'diana_photo',
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
      Post(
        id: 'p13',
        author: userByIdx(4), // nursultan_travel
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p13/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
        ],
        caption: 'Кольсайские озера. Жемчужина Тянь-Шаня. Были? #kolsai #nature #kazakhstan #mountains',
        location: 'Кольсайские озера',
        likesCount: 8900,
        commentsCount: 345,
        isLiked: false,
        isSaved: true,
        likedByUsername: 'nursultan_travel',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'p14',
        author: userByIdx(10), // bekzat_auto
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p14/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
        ],
        caption: 'Subaru WRX STI. Легенда, которая не стареет. #subaru #wrx #jdm #cars',
        location: 'Капчагай',
        likesCount: 1890,
        commentsCount: 78,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Post(
        id: 'p15',
        author: userByIdx(11), // ainur_books
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p15/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Топ-5 книг этого месяца. Листайте! Какие читали? #books #reading #bookstagram',
        likesCount: 2100,
        commentsCount: 167,
        isLiked: true,
        isSaved: false,
        likedByUsername: 'kamila_yoga',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      Post(
        id: 'p16',
        author: userByIdx(5), // aliya_cook
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p16a/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p16b/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Баурсаки и курт - вкус детства. Бабушкин рецепт! #kazakh #food #traditional #baursak',
        location: 'Шымкент, Казахстан',
        likesCount: 4560,
        commentsCount: 201,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'aliya_cook',
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      ),
      Post(
        id: 'p17',
        author: userByIdx(0), // timur_dev
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p17/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Конференция DevFest Almaty. Выступил с докладом про архитектуру. Спасибо организаторам! #devfest #tech #almaty',
        location: 'Алматы, Казахстан',
        likesCount: 1234,
        commentsCount: 56,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 12)),
      ),
      Post(
        id: 'p18',
        author: userByIdx(7), // zarina_style
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p18/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Белое платье - классика на все времена. Согласны? #fashion #whitedress #classic #style',
        location: 'Астана, Казахстан',
        likesCount: 7800,
        commentsCount: 289,
        isLiked: true,
        isSaved: false,
        likedByUsername: 'diana_photo',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Post(
        id: 'p19',
        author: userByIdx(2), // arman_fit
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p19/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Результат за 3 месяца. Правильное питание + тренировки = результат. #beforeafter #fitness #progress',
        likesCount: 3450,
        commentsCount: 145,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      Post(
        id: 'p20',
        author: _currentUser,
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p20a/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p20b/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Редизайн мобильного приложения SeeU. До и после. Что думаете? #ux #ui #design #redesign',
        likesCount: 567,
        commentsCount: 45,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'timur_dev',
        createdAt: now.subtract(const Duration(days: 2, hours: 8)),
      ),
      Post(
        id: 'p21',
        author: userByIdx(3), // madina_art
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p21/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'Масло на холсте. "Осень в Алматы". Продается! DM. #art #oilpainting #almaty #autumn',
        location: 'Алматы, Казахстан',
        likesCount: 2890,
        commentsCount: 98,
        isLiked: false,
        isSaved: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Post(
        id: 'p22',
        author: userByIdx(6), // damir_music
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p22/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Новая песня "Жулдыз" уже на всех площадках! Ссылка в био. #newmusic #single #kazakh',
        likesCount: 890,
        commentsCount: 56,
        isLiked: true,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 3, hours: 6)),
      ),
      Post(
        id: 'p23',
        author: userByIdx(9), // kamila_yoga
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p23/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Поза дерева. Баланс начинается изнутри. #yoga #balance #treepose #mindfulness',
        location: 'Алматы, Казахстан',
        likesCount: 1560,
        commentsCount: 67,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 3, hours: 10)),
      ),
      Post(
        id: 'p24',
        author: userByIdx(4), // nursultan_travel
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p24a/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p24b/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p24c/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
        ],
        caption: 'Бишкек - город контрастов. Горы прямо за углом! #bishkek #kyrgyzstan #centralasia #travel',
        location: 'Бишкек, Кыргызстан',
        likesCount: 5670,
        commentsCount: 234,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'timur_dev',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Post(
        id: 'p25',
        author: userByIdx(8), // ruslan_tech
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p25/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Smart-часы 2025: какие выбрать? Сравнение Apple Watch, Galaxy Watch и Pixel Watch. #smartwatch #tech #comparison',
        likesCount: 3400,
        commentsCount: 213,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 4, hours: 6)),
      ),
      Post(
        id: 'p26',
        author: _currentUser,
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p26/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Кофе, скетчбук и вдохновение. Идеальное утро дизайнера. #design #sketch #coffee #morning',
        location: 'Алматы, Казахстан',
        likesCount: 234,
        commentsCount: 18,
        isLiked: false,
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Post(
        id: 'p27',
        author: userByIdx(11), // ainur_books
        media: [
          PostMedia(
            url: 'https://picsum.photos/seed/seeu_p27/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: '"Степь" Абая Кунанбаева. Перечитываю каждый год и нахожу новое. #abai #kazakh #literature #classics',
        likesCount: 1890,
        commentsCount: 89,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'madina_art',
        createdAt: now.subtract(const Duration(days: 5, hours: 8)),
      ),
    ]);

    // Populate _savedPostIds from initial isSaved flags
    for (final p in _posts) {
      if (p.isSaved) _savedPostIds.add(p.id);
    }

    // ------ Stories ------
    _stories.clear();
    final storyUsers = [_currentUser, otherUsers[0], otherUsers[1], otherUsers[2], otherUsers[4], otherUsers[5], otherUsers[7]];
    int storyIdx = 0;
    for (final u in storyUsers) {
      final count = 1 + _rng.nextInt(3); // 1-3 stories
      for (var i = 0; i < count; i++) {
        storyIdx++;
        final hoursAgo = 1 + _rng.nextInt(20);
        _stories.add(Story(
          id: 'story_$storyIdx',
          author: u,
          mediaUrl: 'https://picsum.photos/seed/story_$storyIdx/600/1000',
          mediaType: StoryMediaType.image,
          textOverlay: i == 0 && storyIdx % 3 == 0 ? 'Привет мир!' : null,
          isSeen: u.id == 'me' ? true : (storyIdx % 3 == 0),
          viewsCount: 50 + _rng.nextInt(500),
          createdAt: now.subtract(Duration(hours: hoursAgo)),
          expiresAt: now.subtract(Duration(hours: hoursAgo)).add(const Duration(hours: 24)),
        ));
      }
    }

    // ------ Comments (3-8 per post) ------
    _comments.clear();
    int commentIdx = 0;
    final commentTexts = [
      'Вау, потрясающе!',
      'Очень красиво!',
      'Супер фото!',
      'Класс!',
      'Где это?',
      'Хочу туда!',
      'Круто выглядит!',
      'Вдохновляет!',
      'Какая красота!',
      'Отличная работа!',
      'Это шедевр!',
      'Сохраню себе!',
      'Нереально круто!',
      'Подписалась!',
      'Обожаю твои фото!',
      'Как ты это делаешь?',
      'Талант!',
      'Мечта!',
      'Лучший контент!',
      'Больше такого!',
    ];

    final replyTexts = [
      'Спасибо!',
      'Рада, что нравится!',
      'Благодарю!',
      'Приятно слышать!',
      'Ты лучше!',
      'Да, это было здорово!',
      'Обязательно попробуй!',
      'Скоро будет еще!',
    ];

    for (final post in _posts) {
      final count = 3 + _rng.nextInt(6); // 3-8 comments
      for (var i = 0; i < count; i++) {
        commentIdx++;
        final commentAuthor = otherUsers[_rng.nextInt(otherUsers.length)];
        final parentId = 'c_$commentIdx';
        final hoursAgo = 1 + _rng.nextInt(48);

        // Create 0-2 replies for this comment
        final replyCount = _rng.nextInt(3);
        final replies = <Comment>[];
        for (var r = 0; r < replyCount; r++) {
          commentIdx++;
          replies.add(Comment(
            id: 'c_$commentIdx',
            postId: post.id,
            author: otherUsers[_rng.nextInt(otherUsers.length)],
            text: replyTexts[_rng.nextInt(replyTexts.length)],
            likesCount: _rng.nextInt(20),
            isLiked: _rng.nextBool(),
            parentId: parentId,
            createdAt: now.subtract(Duration(hours: hoursAgo - 1, minutes: _rng.nextInt(60))),
          ));
        }

        _comments.add(Comment(
          id: parentId,
          postId: post.id,
          author: commentAuthor,
          text: commentTexts[_rng.nextInt(commentTexts.length)],
          likesCount: _rng.nextInt(50),
          isLiked: _rng.nextBool(),
          replies: replies,
          repliesCount: replies.length,
          createdAt: now.subtract(Duration(hours: hoursAgo)),
        ));
      }
    }

    // ------ Notifications (15+) ------
    _notifications.clear();
    _notifications.addAll([
      AppNotification(
        id: 'n1',
        type: NotificationType.like,
        fromUser: otherUsers[0],
        postId: 'p12',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p12/100/100',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.follow,
        fromUser: otherUsers[10],
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.comment,
        fromUser: otherUsers[1],
        postId: 'p20',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p20a/100/100',
        commentText: 'Отличный редизайн!',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.like,
        fromUser: otherUsers[3],
        postId: 'p26',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p26/100/100',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n5',
        type: NotificationType.mention,
        fromUser: otherUsers[0],
        postId: 'p17',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p17/100/100',
        commentText: 'Посмотрите работу @aidana_k',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n6',
        type: NotificationType.follow,
        fromUser: otherUsers[11],
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n7',
        type: NotificationType.reply,
        fromUser: otherUsers[2],
        postId: 'p12',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p12/100/100',
        commentText: 'Очень стильно!',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: 'n8',
        type: NotificationType.like,
        fromUser: otherUsers[7],
        postId: 'p20',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p20a/100/100',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'n9',
        type: NotificationType.comment,
        fromUser: otherUsers[4],
        postId: 'p26',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p26/100/100',
        commentText: 'Мечта интроверта!',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'n10',
        type: NotificationType.postTag,
        fromUser: otherUsers[1],
        postId: 'p11',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p11a/100/100',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      AppNotification(
        id: 'n11',
        type: NotificationType.like,
        fromUser: otherUsers[5],
        postId: 'p12',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p12/100/100',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      AppNotification(
        id: 'n12',
        type: NotificationType.follow,
        fromUser: otherUsers[9],
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'n13',
        type: NotificationType.comment,
        fromUser: otherUsers[6],
        postId: 'p12',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p12/100/100',
        commentText: 'Хочу такой стол!',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      AppNotification(
        id: 'n14',
        type: NotificationType.like,
        fromUser: otherUsers[8],
        postId: 'p20',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p20a/100/100',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 'n15',
        type: NotificationType.mention,
        fromUser: otherUsers[3],
        postId: 'p4',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p4a/100/100',
        commentText: '@aidana_k вдохновилась твоей палитрой',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2, hours: 10)),
      ),
      AppNotification(
        id: 'n16',
        type: NotificationType.reply,
        fromUser: otherUsers[0],
        postId: 'p20',
        postThumbnailUrl: 'https://picsum.photos/seed/seeu_p20a/100/100',
        commentText: 'Архитектура огонь!',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      AppNotification(
        id: 'n17',
        type: NotificationType.follow,
        fromUser: otherUsers[4],
        isRead: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ]);

    // ------ Highlights ------
    _highlights.clear();
    _highlights.addAll([
      // Current user highlights
      Highlight(
        id: 'hl1',
        author: _currentUser,
        title: 'Дизайн',
        coverUrl: 'https://picsum.photos/seed/hl1/200/200',
        stories: [
          Story(id: 'hls1', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls1/600/1000', createdAt: now.subtract(const Duration(days: 30)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls2', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls2/600/1000', createdAt: now.subtract(const Duration(days: 28)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 6, 1),
      ),
      Highlight(
        id: 'hl2',
        author: _currentUser,
        title: 'Путешествия',
        coverUrl: 'https://picsum.photos/seed/hl2/200/200',
        stories: [
          Story(id: 'hls3', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls3/600/1000', createdAt: now.subtract(const Duration(days: 60)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls4', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls4/600/1000', createdAt: now.subtract(const Duration(days: 55)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls5', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls5/600/1000', createdAt: now.subtract(const Duration(days: 50)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 4, 15),
      ),
      Highlight(
        id: 'hl3',
        author: _currentUser,
        title: 'Кофе',
        coverUrl: 'https://picsum.photos/seed/hl3/200/200',
        stories: [
          Story(id: 'hls6', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls6/600/1000', createdAt: now.subtract(const Duration(days: 20)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 8, 1),
      ),
      Highlight(
        id: 'hl4',
        author: _currentUser,
        title: 'Работа',
        coverUrl: 'https://picsum.photos/seed/hl4/200/200',
        stories: [
          Story(id: 'hls7', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls7/600/1000', createdAt: now.subtract(const Duration(days: 10)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls8', author: _currentUser, mediaUrl: 'https://picsum.photos/seed/hls8/600/1000', createdAt: now.subtract(const Duration(days: 8)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 9, 1),
      ),
      // diana_photo highlights
      Highlight(
        id: 'hl5',
        author: otherUsers[1],
        title: 'Портреты',
        coverUrl: 'https://picsum.photos/seed/hl5/200/200',
        stories: [
          Story(id: 'hls9', author: otherUsers[1], mediaUrl: 'https://picsum.photos/seed/hls9/600/1000', createdAt: now.subtract(const Duration(days: 40)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls10', author: otherUsers[1], mediaUrl: 'https://picsum.photos/seed/hls10/600/1000', createdAt: now.subtract(const Duration(days: 35)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 3, 1),
      ),
      Highlight(
        id: 'hl6',
        author: otherUsers[1],
        title: 'Пейзажи',
        coverUrl: 'https://picsum.photos/seed/hl6/200/200',
        stories: [
          Story(id: 'hls11', author: otherUsers[1], mediaUrl: 'https://picsum.photos/seed/hls11/600/1000', createdAt: now.subtract(const Duration(days: 25)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 5, 1),
      ),
      Highlight(
        id: 'hl7',
        author: otherUsers[1],
        title: 'Backstage',
        coverUrl: 'https://picsum.photos/seed/hl7/200/200',
        stories: [
          Story(id: 'hls12', author: otherUsers[1], mediaUrl: 'https://picsum.photos/seed/hls12/600/1000', createdAt: now.subtract(const Duration(days: 15)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls13', author: otherUsers[1], mediaUrl: 'https://picsum.photos/seed/hls13/600/1000', createdAt: now.subtract(const Duration(days: 12)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 7, 1),
      ),
      // nursultan_travel highlights
      Highlight(
        id: 'hl8',
        author: otherUsers[4],
        title: 'Казахстан',
        coverUrl: 'https://picsum.photos/seed/hl8/200/200',
        stories: [
          Story(id: 'hls14', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls14/600/1000', createdAt: now.subtract(const Duration(days: 90)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls15', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls15/600/1000', createdAt: now.subtract(const Duration(days: 85)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls16', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls16/600/1000', createdAt: now.subtract(const Duration(days: 80)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 1, 1),
      ),
      Highlight(
        id: 'hl9',
        author: otherUsers[4],
        title: 'Европа',
        coverUrl: 'https://picsum.photos/seed/hl9/200/200',
        stories: [
          Story(id: 'hls17', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls17/600/1000', createdAt: now.subtract(const Duration(days: 120)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2023, 11, 1),
      ),
      Highlight(
        id: 'hl10',
        author: otherUsers[4],
        title: 'Азия',
        coverUrl: 'https://picsum.photos/seed/hl10/200/200',
        stories: [
          Story(id: 'hls18', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls18/600/1000', createdAt: now.subtract(const Duration(days: 150)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls19', author: otherUsers[4], mediaUrl: 'https://picsum.photos/seed/hls19/600/1000', createdAt: now.subtract(const Duration(days: 145)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2023, 8, 1),
      ),
      // zarina_style highlights
      Highlight(
        id: 'hl11',
        author: otherUsers[7],
        title: 'OOTD',
        coverUrl: 'https://picsum.photos/seed/hl11/200/200',
        stories: [
          Story(id: 'hls20', author: otherUsers[7], mediaUrl: 'https://picsum.photos/seed/hls20/600/1000', createdAt: now.subtract(const Duration(days: 5)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 10, 1),
      ),
      Highlight(
        id: 'hl12',
        author: otherUsers[7],
        title: 'Покупки',
        coverUrl: 'https://picsum.photos/seed/hl12/200/200',
        stories: [
          Story(id: 'hls21', author: otherUsers[7], mediaUrl: 'https://picsum.photos/seed/hls21/600/1000', createdAt: now.subtract(const Duration(days: 18)), expiresAt: now.add(const Duration(days: 365))),
          Story(id: 'hls22', author: otherUsers[7], mediaUrl: 'https://picsum.photos/seed/hls22/600/1000', createdAt: now.subtract(const Duration(days: 16)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 9, 15),
      ),
      Highlight(
        id: 'hl13',
        author: otherUsers[7],
        title: 'Beauty',
        coverUrl: 'https://picsum.photos/seed/hl13/200/200',
        stories: [
          Story(id: 'hls23', author: otherUsers[7], mediaUrl: 'https://picsum.photos/seed/hls23/600/1000', createdAt: now.subtract(const Duration(days: 22)), expiresAt: now.add(const Duration(days: 365))),
        ],
        createdAt: DateTime(2024, 8, 20),
      ),
    ]);

    // ------ Chats & Messages ------
    _chats.clear();
    _chatMessages.clear();

    final chatPeers = [otherUsers[0], otherUsers[1], otherUsers[4], otherUsers[5], otherUsers[7], otherUsers[3]];
    final chatConversations = <List<_MsgTemplate>>[
      // Chat with timur_dev
      [
        _MsgTemplate('me', 'Привет! Видел твой доклад на DevFest. Круто!', 48),
        _MsgTemplate('u1', 'Спасибо! Рад, что понравилось', 47),
        _MsgTemplate('me', 'Можешь скинуть слайды?', 46),
        _MsgTemplate('u1', 'Да, конечно! Сейчас найду и скину', 45),
        _MsgTemplate('u1', 'Вот ссылка: slides.dev/timur-devfest', 44),
        _MsgTemplate('me', 'Супер, спасибо!', 43),
        _MsgTemplate('u1', 'Если будут вопросы - пиши', 42),
        _MsgTemplate('me', 'Кстати, ты используешь Riverpod или Bloc?', 20),
        _MsgTemplate('u1', 'Riverpod в последних проектах. Проще и чище', 19),
        _MsgTemplate('me', 'Согласна, мне тоже нравится', 18),
      ],
      // Chat with diana_photo
      [
        _MsgTemplate('u2', 'Айдана, привет! Хочу предложить коллаборацию', 72),
        _MsgTemplate('me', 'Привет! Интересно, расскажи подробнее', 71),
        _MsgTemplate('u2', 'Я делаю серию портретов, нужен дизайн для выставки', 70),
        _MsgTemplate('me', 'О, звучит здорово! Когда выставка?', 69),
        _MsgTemplate('u2', 'В конце мая. Успеем?', 68),
        _MsgTemplate('me', 'Да, вполне. Давай встретимся и обсудим', 67),
        _MsgTemplate('u2', 'Завтра в 15:00 удобно?', 24),
        _MsgTemplate('me', 'Да, идеально!', 23),
        _MsgTemplate('u2', 'Отлично, тогда в кофейне на Абая', 22),
        _MsgTemplate('me', 'Договорились!', 21),
        _MsgTemplate('u2', 'До встречи!', 3),
      ],
      // Chat with nursultan_travel
      [
        _MsgTemplate('me', 'Нурсултан, потрясающие фото Кольсая!', 96),
        _MsgTemplate('u5', 'Спасибо! Это одно из моих любимых мест', 95),
        _MsgTemplate('me', 'Когда лучше ехать?', 94),
        _MsgTemplate('u5', 'Сентябрь - идеально. Осенние краски невероятные', 93),
        _MsgTemplate('u5', 'Могу дать контакт проводника', 92),
        _MsgTemplate('me', 'Было бы супер!', 91),
        _MsgTemplate('u5', '+7 707 123 4567, Ерлан. Скажи что от меня', 90),
        _MsgTemplate('me', 'Спасибо большое!', 89),
      ],
      // Chat with aliya_cook
      [
        _MsgTemplate('u6', 'Привет! Спасибо за лайк рецепта', 36),
        _MsgTemplate('me', 'Привет! Бешбармак выглядел потрясающе', 35),
        _MsgTemplate('u6', 'Попробуй приготовить! Рецепт в посте', 34),
        _MsgTemplate('me', 'Обязательно попробую на выходных', 33),
        _MsgTemplate('u6', 'Если что, пиши - подскажу нюансы', 32),
        _MsgTemplate('me', 'Спасибо! А курт где лучше купить?', 10),
        _MsgTemplate('u6', 'На Зеленом базаре, второй ряд слева. Там самый вкусный', 9),
        _MsgTemplate('me', 'Записала, спасибо!', 8),
      ],
      // Chat with zarina_style
      [
        _MsgTemplate('u8', 'Айдана, обожаю твои дизайны!', 120),
        _MsgTemplate('me', 'Зарина, спасибо! Я фанатка твоего стиля', 119),
        _MsgTemplate('u8', 'Можешь сделать оформление для моего блога?', 118),
        _MsgTemplate('me', 'Конечно! Давай обсудим что нужно', 117),
        _MsgTemplate('u8', 'Новые обложки для хайлайтов и шаблоны для постов', 116),
        _MsgTemplate('me', 'Поняла. Скину портфолио и примеры завтра', 115),
        _MsgTemplate('u8', 'Жду!', 114),
        _MsgTemplate('me', 'Отправила на почту. Посмотри когда будет время', 50),
        _MsgTemplate('u8', 'Посмотрела! Все нравится, давай начинать', 49),
        _MsgTemplate('me', 'Отлично!', 48),
        _MsgTemplate('u8', 'Когда будет готово примерно?', 5),
        _MsgTemplate('me', 'Через неделю первые варианты покажу', 4),
        _MsgTemplate('u8', 'Супер, жду с нетерпением!', 2),
      ],
      // Chat with madina_art
      [
        _MsgTemplate('me', 'Мадина, привет! Та картина маслом еще продается?', 30),
        _MsgTemplate('u4', 'Привет! Да, еще в наличии', 29),
        _MsgTemplate('me', 'Какой размер?', 28),
        _MsgTemplate('u4', '60x80 см, холст, масло', 27),
        _MsgTemplate('me', 'Красота! Сколько стоит?', 26),
        _MsgTemplate('u4', 'Написала в DM цену. Для подписчиков скидка', 25),
      ],
    ];

    for (var chatIdx = 0; chatIdx < chatPeers.length; chatIdx++) {
      final chatId = 'chat_${chatIdx + 1}';
      final templates = chatConversations[chatIdx];
      ChatMessage? lastMsg;

      for (var msgIdx = 0; msgIdx < templates.length; msgIdx++) {
        final t = templates[msgIdx];
        final msg = ChatMessage(
          id: 'msg_${chatIdx + 1}_${msgIdx + 1}',
          chatId: chatId,
          senderId: t.senderId,
          text: t.text,
          createdAt: now.subtract(Duration(hours: t.hoursAgo)),
          isRead: msgIdx < templates.length - 1 || t.senderId == 'me',
        );
        _chatMessages.add(msg);
        if (lastMsg == null || msg.createdAt.isAfter(lastMsg.createdAt)) {
          lastMsg = msg;
        }
      }

      // Count unread (messages from other user that are not read)
      final unread = _chatMessages
          .where((m) => m.chatId == chatId && m.senderId != 'me' && !m.isRead)
          .length;

      _chats.add(Chat(
        id: chatId,
        otherUser: chatPeers[chatIdx],
        lastMessage: lastMsg,
        unreadCount: unread,
        updatedAt: lastMsg?.createdAt ?? now,
      ));
    }
  }

  // =========================================================================
  // AUTH
  // =========================================================================

  User get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<User> login(String email, String password) async {
    await _delay();
    _isAuthenticated = true;
    return _currentUser;
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _delay();
    _currentUser = User(
      id: 'me',
      username: username,
      fullName: fullName,
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  Future<void> logout() async {
    await _delay();
    _isAuthenticated = false;
  }

  Future<bool> checkUsername(String username) async {
    await _delay();
    return !_users.any((u) => u.username.toLowerCase() == username.toLowerCase());
  }

  // =========================================================================
  // FEED
  // =========================================================================

  Future<List<Post>> getFeed({int page = 0, int limit = 10}) async {
    await _delay();
    final start = page * limit;
    if (start >= _posts.length) return [];
    final end = (start + limit).clamp(0, _posts.length);
    return _posts.sublist(start, end);
  }

  Future<Post> getPost(String id) async {
    await _delay();
    return _posts.firstWhere((p) => p.id == id);
  }

  Future<void> toggleLike(String postId) async {
    await _delay();
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    final newIsLiked = !post.isLiked;
    _posts[idx] = post.copyWith(
      isLiked: newIsLiked,
      likesCount: newIsLiked ? post.likesCount + 1 : post.likesCount - 1,
    );
  }

  Future<void> toggleSave(String postId) async {
    await _delay();
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    final newIsSaved = !post.isSaved;
    _posts[idx] = post.copyWith(isSaved: newIsSaved);
    if (newIsSaved) {
      _savedPostIds.add(postId);
    } else {
      _savedPostIds.remove(postId);
    }
  }

  Future<Post> createPost({
    required String imageUrl,
    String? caption,
    String? location,
  }) async {
    await _delay();
    final post = Post(
      id: _genId(),
      author: _currentUser,
      media: [
        PostMedia(url: imageUrl, type: MediaType.image, aspectRatio: 1.0),
      ],
      caption: caption,
      location: location,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, post);

    // Update current user post count
    _currentUser = _currentUser.copyWith(postsCount: _currentUser.postsCount + 1);
    _updateUserInList(_currentUser);

    return post;
  }

  Future<void> deletePost(String postId) async {
    await _delay();
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    _posts.removeAt(idx);
    _savedPostIds.remove(postId);
    _comments.removeWhere((c) => c.postId == postId);

    if (post.author.id == _currentUser.id) {
      _currentUser = _currentUser.copyWith(postsCount: (_currentUser.postsCount - 1).clamp(0, 999999));
      _updateUserInList(_currentUser);
    }
  }

  // =========================================================================
  // STORIES
  // =========================================================================

  Future<List<StoryGroup>> getStories() async {
    await _delay();
    final grouped = <String, List<Story>>{};
    for (final s in _stories) {
      if (!s.isExpired) {
        grouped.putIfAbsent(s.author.id, () => []).add(s);
      }
    }
    final groups = <StoryGroup>[];
    for (final entry in grouped.entries) {
      final stories = entry.value..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      groups.add(StoryGroup(
        author: stories.first.author,
        stories: stories,
        allSeen: stories.every((s) => s.isSeen),
      ));
    }
    // Current user first, then unseen first
    groups.sort((a, b) {
      if (a.author.id == 'me') return -1;
      if (b.author.id == 'me') return 1;
      if (a.allSeen != b.allSeen) return a.allSeen ? 1 : -1;
      return b.stories.last.createdAt.compareTo(a.stories.last.createdAt);
    });
    return groups;
  }

  Future<void> markStorySeen(String storyId) async {
    await _delay();
    final idx = _stories.indexWhere((s) => s.id == storyId);
    if (idx == -1) return;
    _stories[idx] = _stories[idx].copyWith(isSeen: true);
  }

  Future<void> createStory({required String mediaUrl, String? textOverlay}) async {
    await _delay();
    final story = Story(
      id: _genId(),
      author: _currentUser,
      mediaUrl: mediaUrl,
      textOverlay: textOverlay,
      isSeen: true,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    _stories.add(story);
  }

  // =========================================================================
  // COMMENTS
  // =========================================================================

  Future<List<Comment>> getComments(String postId) async {
    await _delay();
    return _comments.where((c) => c.postId == postId && c.parentId == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Comment> addComment(String postId, String text, {String? parentId}) async {
    await _delay();
    final comment = Comment(
      id: _genId(),
      postId: postId,
      author: _currentUser,
      text: text,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    if (parentId != null) {
      // Add as reply to parent
      final parentIdx = _comments.indexWhere((c) => c.id == parentId);
      if (parentIdx != -1) {
        final parent = _comments[parentIdx];
        _comments[parentIdx] = parent.copyWith(
          replies: [...parent.replies, comment],
          repliesCount: parent.repliesCount + 1,
        );
      }
    } else {
      _comments.add(comment);
    }

    // Update post comment count
    final postIdx = _posts.indexWhere((p) => p.id == postId);
    if (postIdx != -1) {
      final post = _posts[postIdx];
      _posts[postIdx] = post.copyWith(commentsCount: post.commentsCount + 1);
    }

    return comment;
  }

  Future<void> toggleCommentLike(String commentId) async {
    await _delay();
    // Check top-level comments
    final idx = _comments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      final c = _comments[idx];
      final newIsLiked = !c.isLiked;
      _comments[idx] = c.copyWith(
        isLiked: newIsLiked,
        likesCount: newIsLiked ? c.likesCount + 1 : c.likesCount - 1,
      );
      return;
    }
    // Check replies
    for (var i = 0; i < _comments.length; i++) {
      final parent = _comments[i];
      final rIdx = parent.replies.indexWhere((r) => r.id == commentId);
      if (rIdx != -1) {
        final r = parent.replies[rIdx];
        final newIsLiked = !r.isLiked;
        final updatedReplies = List<Comment>.from(parent.replies);
        updatedReplies[rIdx] = r.copyWith(
          isLiked: newIsLiked,
          likesCount: newIsLiked ? r.likesCount + 1 : r.likesCount - 1,
        );
        _comments[i] = parent.copyWith(replies: updatedReplies);
        return;
      }
    }
  }

  // =========================================================================
  // USERS / PROFILES
  // =========================================================================

  Future<User> getProfile(String username) async {
    await _delay();
    return _users.firstWhere(
      (u) => u.username == username,
      orElse: () => _currentUser,
    );
  }

  Future<List<Post>> getUserPosts(String username) async {
    await _delay();
    return _posts.where((p) => p.author.username == username).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Post>> getUserSavedPosts() async {
    await _delay();
    return _posts.where((p) => _savedPostIds.contains(p.id)).toList();
  }

  Future<List<Post>> getUserTaggedPosts(String username) async {
    await _delay();
    // Simulate some tagged posts (return a subset of posts from other users)
    return _posts
        .where((p) => p.author.username != username && p.caption != null && p.caption!.contains('@'))
        .take(5)
        .toList();
  }

  Future<List<Highlight>> getUserHighlights(String username) async {
    await _delay();
    return _highlights.where((h) => h.author.username == username).toList();
  }

  Future<void> toggleFollow(String username) async {
    await _delay();
    final idx = _users.indexWhere((u) => u.username == username);
    if (idx == -1) return;

    final user = _users[idx];
    final nowFollowing = !_followingUsernames.contains(username);

    if (nowFollowing) {
      _followingUsernames.add(username);
    } else {
      _followingUsernames.remove(username);
    }

    // Update target user
    _users[idx] = user.copyWith(
      isFollowing: nowFollowing,
      followersCount: nowFollowing ? user.followersCount + 1 : (user.followersCount - 1).clamp(0, 999999),
    );

    // Update current user's following count
    _currentUser = _currentUser.copyWith(
      followingCount: nowFollowing ? _currentUser.followingCount + 1 : (_currentUser.followingCount - 1).clamp(0, 999999),
    );
    _updateUserInList(_currentUser);

    // Update author in posts
    _updateAuthorInPosts(username, _users[idx]);
  }

  Future<List<User>> getFollowers(String username) async {
    await _delay();
    // Return a realistic subset of users as followers
    final target = _users.firstWhere((u) => u.username == username, orElse: () => _currentUser);
    final others = _users.where((u) => u.id != target.id).toList()..shuffle(_rng);
    return others.take((others.length * 0.6).ceil()).toList();
  }

  Future<List<User>> getFollowing(String username) async {
    await _delay();
    if (username == _currentUser.username) {
      return _users.where((u) => _followingUsernames.contains(u.username)).toList();
    }
    final others = _users.where((u) => u.username != username).toList()..shuffle(_rng);
    return others.take((others.length * 0.5).ceil()).toList();
  }

  Future<User> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? website,
    String? avatarUrl,
  }) async {
    await _delay();
    _currentUser = _currentUser.copyWith(
      fullName: fullName ?? _currentUser.fullName,
      username: username ?? _currentUser.username,
      bio: bio ?? _currentUser.bio,
      website: website ?? _currentUser.website,
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
    );
    _updateUserInList(_currentUser);
    return _currentUser;
  }

  // =========================================================================
  // SEARCH
  // =========================================================================

  Future<List<User>> searchUsers(String query) async {
    await _delay();
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _users.where((u) =>
        u.username.toLowerCase().contains(q) ||
        u.fullName.toLowerCase().contains(q)).toList();
  }

  Future<List<Post>> searchPosts(String query) async {
    await _delay();
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _posts.where((p) =>
        (p.caption?.toLowerCase().contains(q) ?? false) ||
        (p.location?.toLowerCase().contains(q) ?? false)).toList();
  }

  Future<List<Post>> getExplorePosts() async {
    await _delay();
    final shuffled = List<Post>.from(_posts)..shuffle(_rng);
    return shuffled;
  }

  // =========================================================================
  // NOTIFICATIONS
  // =========================================================================

  Future<List<AppNotification>> getNotifications() async {
    await _delay();
    return List.from(_notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markNotificationRead(String id) async {
    await _delay();
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
  }

  Future<void> markAllNotificationsRead() async {
    await _delay();
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  // =========================================================================
  // CHAT
  // =========================================================================

  Future<List<Chat>> getChats() async {
    await _delay();
    return List.from(_chats)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<ChatMessage>> getChatMessages(String chatId) async {
    await _delay();
    // Mark all messages from other user as read
    for (var i = 0; i < _chatMessages.length; i++) {
      final m = _chatMessages[i];
      if (m.chatId == chatId && m.senderId != 'me' && !m.isRead) {
        _chatMessages[i] = m.copyWith(isRead: true);
      }
    }
    // Reset unread count on the chat
    final chatIdx = _chats.indexWhere((c) => c.id == chatId);
    if (chatIdx != -1) {
      _chats[chatIdx] = _chats[chatIdx].copyWith(unreadCount: 0);
    }

    return _chatMessages.where((m) => m.chatId == chatId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<ChatMessage> sendMessage(String chatId, String text) async {
    await _delay();
    final msg = ChatMessage(
      id: _genId(),
      chatId: chatId,
      senderId: 'me',
      text: text,
      createdAt: DateTime.now(),
      isRead: true,
    );
    _chatMessages.add(msg);

    // Update chat's last message
    final chatIdx = _chats.indexWhere((c) => c.id == chatId);
    if (chatIdx != -1) {
      _chats[chatIdx] = _chats[chatIdx].copyWith(
        lastMessage: msg,
        updatedAt: msg.createdAt,
      );
    }

    return msg;
  }

  Future<Chat> startChat(String userId) async {
    await _delay();
    // Check if chat already exists
    final existing = _chats.where((c) => c.otherUser.id == userId);
    if (existing.isNotEmpty) return existing.first;

    final otherUser = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => _users[1],
    );

    final chat = Chat(
      id: _genId(),
      otherUser: otherUser,
      updatedAt: DateTime.now(),
    );
    _chats.add(chat);
    return chat;
  }

  // =========================================================================
  // HELPERS (private)
  // =========================================================================

  void _updateUserInList(User user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
    }
  }

  void _updateAuthorInPosts(String username, User updatedUser) {
    for (var i = 0; i < _posts.length; i++) {
      if (_posts[i].author.username == username) {
        _posts[i] = _posts[i].copyWith(author: updatedUser);
      }
    }
  }
}

// Helper class for building chat messages during init
class _MsgTemplate {
  final String senderId;
  final String text;
  final int hoursAgo;
  const _MsgTemplate(this.senderId, this.text, this.hoursAgo);
}
