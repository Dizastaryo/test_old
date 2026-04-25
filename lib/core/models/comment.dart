import 'user.dart';

class Comment {
  final String id;
  final String postId;
  final User author;
  final String text;
  final int likesCount;
  final bool isLiked;
  final String? parentId;
  final List<Comment> replies;
  final int repliesCount;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
    this.replies = const [],
    this.repliesCount = 0,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final repliesList = (json['replies'] as List?)
            ?.map((r) => Comment.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      text: json['text']?.toString() ?? '',
      likesCount: (json['likes_count'] ?? 0) as int,
      isLiked: (json['is_liked'] ?? false) as bool,
      parentId: json['parent_id']?.toString(),
      replies: repliesList,
      repliesCount: (json['replies_count'] ?? repliesList.length) as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'author': author.toJson(),
    'text': text,
    'likes_count': likesCount,
    'is_liked': isLiked,
    'parent_id': parentId,
    'replies': replies.map((r) => r.toJson()).toList(),
    'replies_count': repliesCount,
    'created_at': createdAt.toIso8601String(),
  };

  Comment copyWith({
    int? likesCount,
    bool? isLiked,
    List<Comment>? replies,
    int? repliesCount,
  }) {
    return Comment(
      id: id,
      postId: postId,
      author: author,
      text: text,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId,
      replies: replies ?? this.replies,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt,
    );
  }

  static List<Comment> demoComments(String postId) {
    final users = User.demoUsers;
    final now = DateTime.now();
    return [
      Comment(
        id: 'c1',
        postId: postId,
        author: users[1],
        text: 'Absolutely stunning! 😍',
        likesCount: 24,
        isLiked: false,
        repliesCount: 2,
        replies: [
          Comment(
            id: 'c1r1',
            postId: postId,
            author: users[0],
            text: 'Thank you so much! 🙏',
            likesCount: 5,
            parentId: 'c1',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          ),
          Comment(
            id: 'c1r2',
            postId: postId,
            author: users[2],
            text: 'Totally agree!',
            likesCount: 2,
            parentId: 'c1',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Comment(
        id: 'c2',
        postId: postId,
        author: users[2],
        text: 'Great shot! Where was this taken?',
        likesCount: 8,
        isLiked: true,
        repliesCount: 1,
        replies: [
          Comment(
            id: 'c2r1',
            postId: postId,
            author: users[0],
            text: 'It\'s in Malibu! 🌊',
            likesCount: 3,
            parentId: 'c2',
            createdAt: now.subtract(const Duration(hours: 3, minutes: 15)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Comment(
        id: 'c3',
        postId: postId,
        author: users[0],
        text: 'Love the colors in this one 🎨',
        likesCount: 15,
        isLiked: false,
        repliesCount: 0,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }
}
