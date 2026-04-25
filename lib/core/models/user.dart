class User {
  final String id;
  final String username;
  final String fullName;
  final String? bio;
  final String? website;
  final String? avatarUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isPrivate;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    this.bio,
    this.website,
    this.avatarUrl,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isPrivate = false,
    this.isVerified = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      bio: json['bio']?.toString(),
      website: json['website']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
      postsCount: (json['posts_count'] ?? json['postsCount'] ?? 0) as int,
      followersCount: (json['followers_count'] ?? json['followersCount'] ?? 0) as int,
      followingCount: (json['following_count'] ?? json['followingCount'] ?? 0) as int,
      isFollowing: (json['is_following'] ?? json['isFollowing'] ?? false) as bool,
      isPrivate: (json['is_private'] ?? json['isPrivate'] ?? false) as bool,
      isVerified: (json['is_verified'] ?? json['isVerified'] ?? false) as bool,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'website': website,
      'avatar_url': avatarUrl,
      'posts_count': postsCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_following': isFollowing,
      'is_private': isPrivate,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    bool? isPrivate,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isPrivate: isPrivate ?? this.isPrivate,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Demo users for offline mode
  static List<User> get demoUsers => [
    User(
      id: '1',
      username: 'alex_photo',
      fullName: 'Alex Johnson',
      bio: 'Photographer & traveler 📸',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      postsCount: 142,
      followersCount: 8420,
      followingCount: 312,
      createdAt: DateTime(2022, 1, 1),
    ),
    User(
      id: '2',
      username: 'maria_design',
      fullName: 'Maria Garcia',
      bio: 'UI/UX Designer ✨',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      postsCount: 87,
      followersCount: 15600,
      followingCount: 240,
      createdAt: DateTime(2021, 6, 15),
    ),
    User(
      id: '3',
      username: 'john_dev',
      fullName: 'John Smith',
      bio: 'Flutter Developer 💙',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      postsCount: 56,
      followersCount: 3200,
      followingCount: 185,
      createdAt: DateTime(2023, 2, 10),
    ),
  ];

  static User get demoMe => User(
    id: '0',
    username: 'me_user',
    fullName: 'My Name',
    bio: 'Living my best life 🌟',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    postsCount: 24,
    followersCount: 512,
    followingCount: 380,
    createdAt: DateTime(2023, 1, 1),
  );
}
