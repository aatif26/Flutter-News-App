import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/news_service.dart';
import '../models/article.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the NewsService for updates
    final newsService = Provider.of<NewsService>(context);

    // Call the fetch function only once when the widget initializes
    if (newsService.articles.isEmpty && !newsService.isLoading && newsService.errorMessage.isEmpty) {
      // Use WidgetsBinding to ensure build is complete before calling async function
      WidgetsBinding.instance.addPostFrameCallback((_) {
        newsService.fetchArticles();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter News Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => newsService.fetchArticles(),
          ),
        ],
      ),
      body: newsService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsService.errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${newsService.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: newsService.articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: newsService.articles[index]);
                  },
                ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (article.url.isNotEmpty && await canLaunchUrl(Uri.parse(article.url))) {
          await launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication);
        } else {
          // Optional: Show a SnackBar or dialog if the URL cannot be launched
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open article link.')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(height: 200, color: Colors.grey[300]),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),
            // Text Content Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Source: ${article.sourceName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}