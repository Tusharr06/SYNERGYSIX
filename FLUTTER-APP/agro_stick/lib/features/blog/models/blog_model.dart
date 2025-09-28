class BlogModel {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String author;
  final String authorImage;
  final DateTime publishedDate;
  final String imageUrl;
  final String category;
  final int readTime; // in minutes
  final List<String> tags;

  BlogModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.author,
    required this.authorImage,
    required this.publishedDate,
    required this.imageUrl,
    required this.category,
    required this.readTime,
    required this.tags,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      authorImage: json['authorImage'] ?? '',
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      readTime: json['readTime'] ?? 5,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'author': author,
      'authorImage': authorImage,
      'publishedDate': publishedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
      'readTime': readTime,
      'tags': tags,
    };
  }
}






