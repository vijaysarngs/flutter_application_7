import 'package:flutter/material.dart';
import 'package:beyondheadlines/pages/auth/articles/article_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import 'package:beyondheadlines/utils/user_manager.dart';

String? ip = UserManager.instance.ipCurrent;

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Article>> articles;

  @override
  void initState() {
    super.initState();
    articles = fetchArticlesFromFlask(
        widget.category); // Fetch articles on initialization
  }

  Future<List<Article>> fetchArticlesFromFlask(String category) async {
    final String serverAddress =
        'http://$ip:40733/category-news?category=$category';

    try {
      final response = await http.get(Uri.parse(serverAddress));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Ensure the API response has 'articles'
        if (data['status'] == 'success') {
          List<dynamic> articlesData = data['articles'];
          // Filter out articles without images and map them to the Article model
          List<Article> filteredArticles = articlesData
              .map((json) => Article.fromJson(json))
              .where((article) => article.imageUrl.isNotEmpty)
              .toList();

          return filteredArticles;
        } else {
          throw Exception('No articles found in the response');
        }
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  @override
  void didUpdateWidget(CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      // If the category has changed, fetch the new articles
      setState(() {
        articles = fetchArticlesFromFlask(widget.category);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} News'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<Article>>(
        future: articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final article = snapshot.data![index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(
                            articleUrl:
                                article.url, // Updated to use 'url' field
                            articleSource: article.source),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image or Placeholder
                      if (article.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            article.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      const SizedBox(height: 8),

                      // Category Tag and Date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              widget.category, // Dynamically show the category
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.publishedAt,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title and Description
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
