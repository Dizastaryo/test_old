import 'user.dart';

enum MediaType { image, video, carousel }

class PostMedia {
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final double? aspectRatio;

  const PostMedia({
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.aspectRatio,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      url: json['url']?.toString() ?? '',
      type: _parseMediaType(json['type']?.toString()),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
    );
  }

  static MediaType _parseMediaType(String? type) {
    switch (type) {
      case 'video':
        return MediaType.video;
      case 'carousel':
        return MediaType.carousel;
      default:
        return MediaType.image;
    }
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'type': type.name,
    'thumbnail_url': thumbnailUrl,
    'aspect_ratio': aspectRatio,
  };
}

class Post {
  final String id;
  final User author;
  final List<PostMedia> media;
  final String? caption;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final String? likedByUsername;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.author,
    required this.media,
    this.caption,
    this.location,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.likedByUsername,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List?)
            ?.map((m) => PostMedia.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return Post(
      id: json['id']?.toString() ?? '',
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      media: mediaList,
      caption: json['caption']?.toString(),
      location: json['location']?.toString(),
      likesCount: (json['likes_count'] ?? json['likesCount'] ?? 0) as int,
      commentsCount: (json['comments_count'] ?? json['commentsCount'] ?? 0) as int,
      isLiked: (json['is_liked'] ?? json['isLiked'] ?? false) as bool,
      isSaved: (json['is_saved'] ?? json['isSaved'] ?? false) as bool,
      likedByUsername: json['liked_by_username']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'media': media.map((m) => m.toJson()).toList(),
    'caption': caption,
    'location': location,
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'is_liked': isLiked,
    'is_saved': isSaved,
    'liked_by_username': likedByUsername,
    'created_at': createdAt.toIso8601String(),
  };

  Post copyWith({
    String? id,
    User? author,
    List<PostMedia>? media,
    String? caption,
    String? location,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    String? likedByUsername,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      likedByUsername: likedByUsername ?? this.likedByUsername,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Demo posts for offline/dev mode
  static List<Post> get demoPosts {
    final users = User.demoUsers;
    return [
      Post(
        id: '1',
        author: users[0],
        media: [
          const PostMedia(
            url: 'https://picsum.photos/seed/p1/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Beautiful sunset at the beach 🌅 #photography #travel #sunset',
        location: 'Malibu, California',
        likesCount: 1243,
        commentsCount: 47,
        isLiked: false,
        isSaved: false,
        likedByUsername: 'maria_design',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: '2',
        author: users[1],
        media: [
          const PostMedia(
            url: 'https://picsum.photos/seed/p2/800/1000',
            type: MediaType.image,
            aspectRatio: 0.8,
          ),
        ],
        caption: 'New design system I\'ve been working on. What do you think? 💭',
        likesCount: 892,
        commentsCount: 63,
        isLiked: true,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        id: '3',
        author: users[2],
        media: [
          const PostMedia(
            url: 'https://picsum.photos/seed/p3/800/600',
            type: MediaType.image,
            aspectRatio: 1.33,
          ),
        ],
        caption: 'Just shipped a new Flutter app! 🚀 #flutter #mobile #dev',
        likesCount: 456,
        commentsCount: 28,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: '4',
        author: users[0],
        media: [
          const PostMedia(
            url: 'https://picsum.photos/seed/p4/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Morning coffee and good vibes ☕',
        location: 'New York City',
        likesCount: 2100,
        commentsCount: 91,
        isLiked: true,
        isSaved: false,
        likedByUsername: 'john_dev',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Post(
        id: '5',
        author: users[1],
        media: [
          const PostMedia(
            url: 'https://picsum.photos/seed/p5/800/800',
            type: MediaType.image,
            aspectRatio: 1.0,
          ),
        ],
        caption: 'Colors that inspire ✨ #design #color #inspiration',
        likesCount: 3400,
        commentsCount: 112,
        isLiked: false,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
