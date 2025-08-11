import 'package:flutter/material.dart';

class NewsFilterScreen extends StatefulWidget {
  final List<dynamic> selectedCategories;
  final List<dynamic> selectedSources;
  final List<dynamic> newsArticles;

  const NewsFilterScreen({
    Key? key,
    required this.selectedCategories,
    required this.selectedSources,
    required this.newsArticles,
  }) : super(key: key);

  @override
  _NewsFilterScreenState createState() => _NewsFilterScreenState();
}

class _NewsFilterScreenState extends State<NewsFilterScreen> {
  late List<dynamic> filteredArticles;
  late List<String> categories;
  late List<String> sources;

  @override
  void initState() {
    super.initState();
    // Initialize with safe conversions
    categories = widget.selectedCategories
        .map((e) => e.toString())
        .toList()
        .cast<String>();

    sources =
        widget.selectedSources.map((e) => e.toString()).toList().cast<String>();

    filteredArticles = _filterArticles();
  }

  List<dynamic> _filterArticles() {
    return widget.newsArticles.where((article) {
      // Null-safe category and source checks
      bool matchesCategory = categories.isEmpty ||
          categories.contains(article['category']?.toString().toLowerCase());

      bool matchesSource = sources.isEmpty ||
          sources.contains(article['source']?.toString().toLowerCase());

      return matchesCategory && matchesSource;
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      filteredArticles = _filterArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Filter (${filteredArticles.length} articles)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
          )
        ],
      ),
      body: Column(
        children: [
          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Categories: '),
                ...[
                  'business',
                  'sports',
                  'politics',
                  'technology',
                  'entertainment'
                ]
                    .map((category) => FilterChip(
                          label: Text(category),
                          selected: categories.contains(category),
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                categories.add(category);
                              } else {
                                categories.remove(category);
                              }
                              _applyFilters();
                            });
                          },
                        ))
                    .toList(),
              ],
            ),
          ),

          // Source Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Sources: '),
                ...['CNN', 'BBC', 'Reuters', 'Associated Press']
                    .map((source) => FilterChip(
                          label: Text(source),
                          selected: sources.contains(source),
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                sources.add(source);
                              } else {
                                sources.remove(source);
                              }
                              _applyFilters();
                            });
                          },
                        ))
                    .toList(),
              ],
            ),
          ),

          // Filtered Articles List
          Expanded(
            child: filteredArticles.isEmpty
                ? const Center(
                    child: Text(
                      'No articles match your current filters',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      return ListTile(
                        title: Text(article['title'] ?? 'Untitled'),
                        subtitle: Text(
                          '${article['source'] ?? 'Unknown Source'} • ${article['category'] ?? 'Uncategorized'}',
                        ),
                        onTap: () {
                          // Navigate to article detail
                          Navigator.pushNamed(context, '/article-detail',
                              arguments: {
                                'title': article['title'] ?? 'Untitled',
                                'source': article['source'] ?? 'Unknown Source',
                                'imageUrl': article['imageUrl'],
                                'publishedAt':
                                    article['publishedAt'] ?? 'Unknown Date',
                                'content': article['content'] ??
                                    'No content available',
                                'link': article['link'],
                              });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
