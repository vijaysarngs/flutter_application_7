import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ArticleListScreen extends StatelessWidget {
  final List<String> selectedSources;

  ArticleListScreen({required this.selectedSources});

  Future<List<dynamic>> fetchArticles() async {
    final queryParams = selectedSources.map((e) => 'sources=$e').join('&');
    final url = 'http://127.0.0.1:40735/news?$queryParams';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load articles');
    }
  }

  void openLink(String url) async {
    final Uri url = Uri.parse('url');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in an external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article['title']),
                subtitle: Text(article['description']),
                leading: article['imageUrl'] != null
                    ? Image.network(
                        article['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : null,
                onTap: () {
                  if (article['link'] != null) {
                    openLink(article['link']);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No link available for this article')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
