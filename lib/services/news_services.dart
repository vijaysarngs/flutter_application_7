// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/article.dart';

class NewsService {
  static const String baseUrl = 'http://your-flask-backend-url:40735/news';

  Future<List<Article>> fetchNews(
      {List<String>? sources, List<String>? categories}) async {
    try {
      // Construct query parameters
      Map<String, List<String>> queryParams = {};
      if (sources != null && sources.isNotEmpty) {
        queryParams['sources'] = sources;
      }
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

      // Build the URI
      final Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: queryParams.map((key, value) =>
            MapEntry(key, value.map((e) => e.toString()).toList())),
      );

      // Make the request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success' && data['articles'] != null) {
          return (data['articles'] as List)
              .map((articleJson) => Article.fromJson(articleJson))
              .toList();
        } else {
          throw Exception('No articles found');
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
