import 'user.dart';
import 'story.dart';

class Highlight {
  final String id;
  final User author;
  final String title;
  final String coverUrl;
  final List<Story> stories;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.author,
    required this.title,
    required this.coverUrl,
    this.stories = const [],
    required this.createdAt,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List?)
            ?.map((s) => Story.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return Highlight(
      id: json['id']?.toString() ?? '',
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      title: json['title']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString() ?? '',
      stories: storiesList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'title': title,
    'cover_url': coverUrl,
    'stories': stories.map((s) => s.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };

  static List<Highlight> demoHighlights(User author) {
    return [
      Highlight(
        id: 'h1',
        author: author,
        title: 'Travel',
        coverUrl: 'https://picsum.photos/seed/h1/200/200',
        createdAt: DateTime(2024, 1, 1),
      ),
      Highlight(
        id: 'h2',
        author: author,
        title: 'Food',
        coverUrl: 'https://picsum.photos/seed/h2/200/200',
        createdAt: DateTime(2024, 2, 1),
      ),
      Highlight(
        id: 'h3',
        author: author,
        title: 'Work',
        coverUrl: 'https://picsum.photos/seed/h3/200/200',
        createdAt: DateTime(2024, 3, 1),
      ),
      Highlight(
        id: 'h4',
        author: author,
        title: 'Friends',
        coverUrl: 'https://picsum.photos/seed/h4/200/200',
        createdAt: DateTime(2024, 4, 1),
      ),
    ];
  }
}
