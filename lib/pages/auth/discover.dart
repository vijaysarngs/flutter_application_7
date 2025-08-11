import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beyondheadlines/utils/user_manager.dart';

String? ip = UserManager.instance.ipCurrent;

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final Set<String> selectedCategories = {};

  Future<void> saveSelectedCategories() async {
    final String email =
        UserManager.instance.email ?? ''; // Retrieve email from UserManager

    if (email.isEmpty) {
      print("Error: Email is missing");
      return;
    }

    final url = 'http://$ip:40734/save-categories'; // Update with Flask URL
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email, // Use email from UserManager
        'categories': selectedCategories.toList(),
      }),
    );

    if (response.statusCode == 200) {
      // Categories saved successfully
      print('Categories saved: ${response.body}');
    } else {
      // Handle the error
      print('Error saving categories: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Search news',
              //     prefixIcon: const Icon(Icons.search),
              //     suffixIcon: const Icon(Icons.tune),
              //     filled: true,
              //     fillColor: Colors.grey[100],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${selectedCategories.length} selected',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    NewsCategoryCard(
                      title: 'Business',
                      newsCount: '120',
                      imagePath: 'assets/business.jpg',
                      isSelected: selectedCategories.contains('Business'),
                      onTap: () => toggleCategory('Business'),
                    ),
                    NewsCategoryCard(
                      title: 'Sports',
                      newsCount: '80',
                      imagePath: 'assets/sports.jpg',
                      isSelected: selectedCategories.contains('Sports'),
                      onTap: () => toggleCategory('Sports'),
                    ),
                    NewsCategoryCard(
                      title: 'Politics',
                      newsCount: '220',
                      imagePath: 'assets/politics.jpg',
                      isSelected: selectedCategories.contains('Politics'),
                      onTap: () => toggleCategory('Politics'),
                    ),
                    NewsCategoryCard(
                      title: 'Fashion & Beauty',
                      newsCount: '97',
                      imagePath: 'assets/fashion.jpg',
                      isSelected:
                          selectedCategories.contains('Fashion & Beauty'),
                      onTap: () => toggleCategory('Fashion & Beauty'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedCategories.isEmpty
                  ? null
                  : () async {
                      await saveSelectedCategories();
                      Navigator.pushNamed(context, '/google-sign-in');
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue to Login page'),
            ),
          ),
        ],
      ),
    );
  }

  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }
}

class NewsCategoryCard extends StatelessWidget {
  final String title;
  final String newsCount;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const NewsCategoryCard({
    Key? key,
    required this.title,
    required this.newsCount,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.red, width: 3) : null,
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$newsCount News',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
