import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService extends ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Replace with your actual NewsAPI key
  final String apiKey = 'YOUR_NEWS_API_KEY_HERE'; 
  final String baseUrl = 'https://newsapi.org/v2/top-headlines';
  final String country = 'us'; // Example: top headlines in the US

  Future<void> fetchArticles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final uri = Uri.parse('$baseUrl?country=$country&apiKey=$apiKey');
    
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          final List<dynamic> articlesJson = data['articles'];
          
          _articles = articlesJson
              .map((json) => Article.fromJson(json))
              .where((article) => article.urlToImage.isNotEmpty) // Filter out articles without images
              .toList();
        } else {
          _errorMessage = data['message'] ?? 'Failed to load news: API error.';
        }
      } else {
        _errorMessage = 'Failed to load news. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while fetching data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}