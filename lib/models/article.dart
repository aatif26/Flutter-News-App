class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String sourceName;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available.',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '', // Placeholder logic goes here if needed
      sourceName: json['source'] != null ? json['source']['name'] : 'Unknown Source',
    );
  }
}