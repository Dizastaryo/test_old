import 'user.dart';

enum StoryMediaType { image, video }

class Story {
  final String id;
  final User author;
  final String mediaUrl;
  final StoryMediaType mediaType;
  final String? textOverlay;
  final bool isSeen;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.id,
    required this.author,
    required this.mediaUrl,
    this.mediaType = StoryMediaType.image,
    this.textOverlay,
    this.isSeen = false,
    this.viewsCount = 0,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id']?.toString() ?? '',
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      mediaUrl: json['media_url']?.toString() ?? '',
      mediaType: json['media_type'] == 'video'
          ? StoryMediaType.video
          : StoryMediaType.image,
      textOverlay: json['text_overlay']?.toString(),
      isSeen: (json['is_seen'] ?? json['isSeen'] ?? false) as bool,
      viewsCount: (json['views_count'] ?? 0) as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString()) ??
              DateTime.now().add(const Duration(hours: 24))
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'media_url': mediaUrl,
    'media_type': mediaType.name,
    'text_overlay': textOverlay,
    'is_seen': isSeen,
    'views_count': viewsCount,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
  };

  Story copyWith({bool? isSeen}) {
    return Story(
      id: id,
      author: author,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      textOverlay: textOverlay,
      isSeen: isSeen ?? this.isSeen,
      viewsCount: viewsCount,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}

class StoryGroup {
  final User author;
  final List<Story> stories;
  final bool allSeen;

  const StoryGroup({
    required this.author,
    required this.stories,
    required this.allSeen,
  });

  factory StoryGroup.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List?)
            ?.map((s) => Story.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];
    return StoryGroup(
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      stories: storiesList,
      allSeen: storiesList.every((s) => s.isSeen),
    );
  }

  static List<StoryGroup> get demoStoryGroups {
    final users = User.demoUsers;
    final now = DateTime.now();
    return [
      StoryGroup(
        author: users[0],
        stories: [
          Story(
            id: 's1',
            author: users[0],
            mediaUrl: 'https://picsum.photos/seed/s1/600/1000',
            isSeen: false,
            createdAt: now.subtract(const Duration(hours: 1)),
            expiresAt: now.add(const Duration(hours: 23)),
          ),
          Story(
            id: 's2',
            author: users[0],
            mediaUrl: 'https://picsum.photos/seed/s2/600/1000',
            isSeen: false,
            createdAt: now.subtract(const Duration(hours: 2)),
            expiresAt: now.add(const Duration(hours: 22)),
          ),
        ],
        allSeen: false,
      ),
      StoryGroup(
        author: users[1],
        stories: [
          Story(
            id: 's3',
            author: users[1],
            mediaUrl: 'https://picsum.photos/seed/s3/600/1000',
            isSeen: true,
            createdAt: now.subtract(const Duration(hours: 3)),
            expiresAt: now.add(const Duration(hours: 21)),
          ),
        ],
        allSeen: true,
      ),
      StoryGroup(
        author: users[2],
        stories: [
          Story(
            id: 's4',
            author: users[2],
            mediaUrl: 'https://picsum.photos/seed/s4/600/1000',
            isSeen: false,
            createdAt: now.subtract(const Duration(hours: 4)),
            expiresAt: now.add(const Duration(hours: 20)),
          ),
        ],
        allSeen: false,
      ),
    ];
  }
}
