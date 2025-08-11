import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:http/http.dart' as http;
import '/models/article.dart';
import 'article_detail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:beyondheadlines/options/category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:beyondheadlines/pages_new/business.dart';
import 'package:beyondheadlines/pages_new/economoy.dart';
import 'package:beyondheadlines/pages_new/sports.dart';
import 'package:beyondheadlines/pages_new/politics.dart';
import 'package:shared_preferences/shared_preferences.dart';

// String? userEmail = UserManager.instance.email;

class GeneralArticlesScreen extends StatefulWidget {
  const GeneralArticlesScreen({Key? key}) : super(key: key);

  @override
  _GeneralArticlesScreenState createState() => _GeneralArticlesScreenState();
}

class _GeneralArticlesScreenState extends State<GeneralArticlesScreen> {
  List<Article> articles = [];
  List<Article> carouselArticles = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCategory = 'General';
  int totalArticles = 0;
  int _currentCarouselIndex = 0;
  final PageController _carouselController =
      PageController(viewportFraction: 0.9);
  final PageController _categoryController = PageController();

  final List<String> categories = [
    'Politics',
    'Sports',
    'Business',
    'Technology',
  ];

  final Map<String, String> categoryImages = {
    'Politics': 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620',
    'Sports': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
    'Business': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf',
    'Technology':
        'https://images.unsplash.com/photo-1518770660439-4636190af475',
  };

  final String placeholderImageUrl = 'assets/images/placeholder.jpg';

  @override
  void initState() {
    super.initState();
    _fetchArticles(selectedCategory);
  }

  Future<void> articleReadUpdate(String userEmail, String articleSource) async {
    String? ip = UserManager.instance.ipCurrent;
    String apiUrl = "http://$ip:40734/update_article_read";
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    UserManager.instance.email = userEmail;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userEmail,
          "source": articleSource,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Article read count updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception(
            "Failed to update article read count: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating article read count: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _fetchArticles(String category) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String? ip = UserManager.instance.ipCurrent;
      final uri = Uri.http('$ip:40733', '/news', {
        'category': "india",
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData['status'] == 'success') {
          List<dynamic> articlesJson = decodedData['articles'] ?? [];

          setState(() {
            articles =
                articlesJson.map((json) => Article.fromJson(json)).toList();
            totalArticles = articles.length;

            if (articles.length > 5) {
              carouselArticles = articles.sublist(0, 5);
              articles = articles.sublist(5);
            } else {
              carouselArticles = articles;
              articles = [];
            }

            isLoading = false;
          });
        } else {
          throw Exception(decodedData['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load articles: ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load articles: $error';
        isLoading = false;
      });
    }
  }

  String getTimeAgo(String? publishedAt) {
    if (publishedAt == null) return '12 hours ago';
    try {
      final dateTime = DateTime.parse(publishedAt);
      return timeago.format(dateTime);
    } catch (e) {
      return '12 hours ago';
    }
  }

  void navigateToArticleDetail(Article? article, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    if (article == null || article.url == null || article.source == null) {
      Fluttertoast.showToast(
        msg: "Article details are missing!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Get the current user email

    if (userEmail == null) {
      Fluttertoast.showToast(
        msg: "User email is missing!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Send data to SQL backend to update the count
      var response = await http.post(
        Uri.parse(
            'http://180.235.121.245:40734/update_category'), // Replace with your backend endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': userEmail,
          'category': 'politics',
        }),
      );

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(
        //   msg: "Article marked as read in politics category.",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.green,
        //   textColor: Colors.white,
        // );
      } else {
        // Fluttertoast.showToast(
        //   msg: "Failed to update category count. Please try again.",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        // );
        print("Error: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("Exception: $e");
    }

    // Navigate to the article detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlePage(
          articleUrl: article.url!,
          articleSource: article.source!,
        ),
      ),
    );
  }

  void navigateToCategoryScreen(String category) {
    Widget targetScreen;

    switch (category.toLowerCase()) {
      case 'politics':
        targetScreen = CategoryScreen3(category: category);
        break;
      case 'sports':
        targetScreen = CategoryScreen4(category: category);
        break;
      case 'technology':
        targetScreen = CategoryScreen2(category: category);
        break;
      case 'business':
        targetScreen = CategoryScreen5(category: category);
        break;
      default:
        targetScreen = CategoryScreen(category: category); // Default screen
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => targetScreen,
      ),
    );
  }

  Widget buildNetworkImage(String? imageUrl,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return CachedNetworkImage(
      imageUrl: imageUrl ??
          'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620',
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 236, 233, 233),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0), // Move the menu icon higher
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final useremail3 = prefs.getString('userEmail');
                if (useremail3 != "guest") {
                  Navigator.pushNamed(context, '/dashboard');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Error"),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        content: const Text(
                            "Please login or signup in the profile page"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final useremail3 = prefs.getString('userEmail');
                if (useremail3 != "guest") {
                  Navigator.pushNamed(context, '/feedback');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Error"),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        content: const Text(
                            "Please login or signup in the profile page"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final useremail3 = prefs.getString('userEmail');
                if (useremail3 != "guest") {
                  Navigator.pushNamed(context, '/edit-profile');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Error"),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        content: const Text(
                            "Please login or signup in the profile page"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('Doom Scroll'),
              onTap: () {
                Navigator.pushNamed(context, '/doom-scroll');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 15.0),
                              // child: IconButton(
                              //   alignment: Alignment.centerLeft,
                              //   icon: const Icon(Icons.arrow_back),
                              //   onPressed: () => Navigator.pop(context),
                              // ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              height: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      navigateToCategoryScreen(category);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            buildNetworkImage(
                                              categoryImages[category] ?? '',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Text(
                                                category,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: Text(
                                                "$totalArticles News",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Banner for "Top News"
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blueAccent, // Background color for the banner
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0,
                                            2), // Subtle shadow below the banner
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    "Top News",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // White text color for contrast
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 230,
                              child: PageView.builder(
                                controller: _carouselController,
                                itemCount: carouselArticles.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentCarouselIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final article = carouselArticles[index];
                                  return GestureDetector(
                                    onTap: () => navigateToArticleDetail(
                                        article, "government"),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                48,
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 120,
                                                  child: buildNetworkImage(
                                                    article.imageUrl ?? '',
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: SizedBox(
                                                    height: 50,
                                                    child: Text(
                                                      article.title ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 2.0,
                                                  ),
                                                  child: Text(
                                                    getTimeAgo(
                                                        article.publishedAt),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final article = articles[index];
                                return GestureDetector(
                                  onTap: () => navigateToArticleDetail(
                                      article, "general"),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                          child: buildNetworkImage(
                                            article.imageUrl ?? '',
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            article.title ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            getTimeAgo(article.publishedAt),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: articles.length,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
