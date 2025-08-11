import 'dart:convert';
import 'package:http/http.dart' as http;

class SummarizationService {
  static const String apiKey = 'YOUR_RAPID_API_KEY';

  static Future<String> summarizeArticle(String url) async {
    final response = await http.get(
      Uri.parse(
          'https://article-extractor-and-summarizer.p.rapidapi.com/summarize?url=$url'),
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'article-extractor-and-summarizer.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary'] ?? 'No summary available';
    } else {
      throw Exception('Failed to summarize article');
    }
  }
}
