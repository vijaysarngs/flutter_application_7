import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:40735/news';

  static Future<List<Article>> fetchArticles(
      List<String> sources, List<String> categories) async {
    final queryParams = {
      'sources': sources,
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> articlesJson = data['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch articles');
    }
  }
}
