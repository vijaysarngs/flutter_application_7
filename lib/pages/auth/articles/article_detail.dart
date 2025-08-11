import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import InAppWebView
import 'package:beyondheadlines/options/fact_checker.dart';
import 'package:beyondheadlines/options/summarization.dart';
import 'package:beyondheadlines/options/bionic.dart';
import 'package:beyondheadlines/options/trend_identifier.dart';
import 'package:beyondheadlines/options/perspec.dart';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:beyondheadlines/options/bias_analysis.dart';

String? ip = UserManager.instance.ipCurrent;

class ArticlePage extends StatefulWidget {
  final String articleUrl;
  final String articleSource;

  const ArticlePage(
      {Key? key, required this.articleUrl, required this.articleSource})
      : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Map<String, dynamic>? articleData;
  List<dynamic> relatedVideos = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchArticleData();
  }

  Future<void> fetchArticleData() async {
    String flaskApiUrl = 'http://$ip:40733/article-details';
    try {
      final response = await http.post(
        Uri.parse(flaskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'url': widget.articleUrl,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          articleData = json.decode(response.body);
        });
        fetchRelatedVideos(articleData?['title'] ?? '');
      } else {
        setState(() {
          errorMessage =
              'Failed to load article: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchRelatedVideos(String title) async {
    String relatedVideosApiUrl = 'http://$ip:40734/get_videos';
    try {
      final response = await http.post(
        Uri.parse(relatedVideosApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('videos')) {
          setState(() {
            relatedVideos = decodedResponse['videos'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load related videos: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void openUrl(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Tone analysis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FactCheckerPage(
                        articleUrl: widget.articleUrl,
                        sourceName: widget.articleSource,
                        articleContent: articleData?['body']),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.balance_outlined),
              title: const Text('Bias Analyzer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ArticleClassifierPage(article: articleData?['body']),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Perspective Blog'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BiasFreeArticleScreen(
                            article: articleData?['body'])));
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Summarize'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SummarizePage(articleUrl: widget.articleUrl),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_bold_outlined),
              title: const Text('Bionic Format'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BionicFormatPage(
                      articleContent: articleData?['body'],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(top: 0.0), // Adjust menu icon position
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Navigate back to the previous screen
              } else {
                // Optional: Handle when there's no screen to go back to
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('No Screen to Go Back'),
                    content: const Text(
                        'You are at the home screen and cannot navigate back.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(), // Close dialog
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        backgroundColor:
            const Color.fromARGB(255, 63, 171, 175), // Match the background
        elevation: 2,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 3), // Push content down
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align at the bottom
                children: [
                  const Text(
                    'B',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Lora', // Adjust to match the "B" font style
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Beyond',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Serif', // Adjust to match the style
                        ),
                      ),
                      Text(
                        'HEADLINES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Serif', // Adjust for smaller text
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(flex: 3), // Push further towards the bottom
            ],
          ),
        ),
        toolbarHeight: 60, // Increased height for better spacing
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articleData?['title'] ?? 'No title available',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Published on: ${articleData?['date'] ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Source: ${widget.articleSource}',
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 16),
                          if (articleData?['image'] != null)
                            Image.network(articleData!['image']),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                articleData?['body'] ?? 'No content available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (relatedVideos.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Related Videos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  color: Color.fromARGB(209, 248, 249, 249),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      height: 200, // Adjust height as needed
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: relatedVideos.length,
                                        itemBuilder: (context, index) {
                                          final video = relatedVideos[index];
                                          return GestureDetector(
                                            onTap: () => openUrl(video['url']),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              width:
                                                  160, // Adjust width as needed
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // Rounded corners
                                                    child: Image.network(
                                                      video['thumbnail'],
                                                      height: 140,
                                                      width:
                                                          160, // Match the width of the container
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    video['title'] ?? '',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _showMoreOptions(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: const Text('More Options'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
      ),
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: WebUri.uri(Uri.parse(url))), // Correct conversion
      ),
    );
  }
}
