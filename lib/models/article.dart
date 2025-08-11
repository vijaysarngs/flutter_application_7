class Article {
  final String title;
  final String source;
  final String imageUrl;
  final String publishedAt;
  final String content;
  final String link;
  final String description;
  final String url;

  // Constructor to initialize the fields
  Article({
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.content,
    required this.link,
    required this.description,
    required this.url,
  });

  // Factory constructor to create an Article object from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title Available',
      source: json['source'] ?? 'Unknown Source',
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: json['publishedAt'] ?? 'Unknown Date',
      content: json['content'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? 'No description available.',
      url: json['url'] ?? '',
    );
  }

  // Method to convert Article object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'content': content,
      'link': link,
      'description': description,
      'url': url,
    };
  }
}
