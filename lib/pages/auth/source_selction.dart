import 'package:flutter/material.dart';
import 'package:beyondheadlines/models/news_source.dart';
import 'package:beyondheadlines/widgets/source_card.dart';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String? ip = UserManager.instance.ipCurrent;

class SourceSelectionScreen extends StatefulWidget {
  const SourceSelectionScreen({Key? key}) : super(key: key);

  @override
  _SourceSelectionScreenState createState() => _SourceSelectionScreenState();
}

class _SourceSelectionScreenState extends State<SourceSelectionScreen> {
  final List<NewsSource> sources = [
    NewsSource(id: 'bbc', name: 'BBC', logo: 'assets/bbc.png'),
    NewsSource(id: 'cnn', name: 'CNN', logo: 'assets/cnn.png'),
    NewsSource(id: 'hindu', name: 'The Hindu', logo: 'assets/hindu.png'),
    NewsSource(id: 'news18', name: 'News18', logo: 'assets/news18.png'),
    NewsSource(id: 'toi', name: 'Times of India', logo: 'assets/toi.png'),
  ];

  Set<String> selectedSources = {};
  final TextEditingController _searchController = TextEditingController();
  List<NewsSource> filteredSources = [];

  @override
  void initState() {
    super.initState();
    filteredSources = sources;
    _searchController.addListener(_filterSources);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSources);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSources() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSources = sources
          .where((source) =>
              source.name.toLowerCase().contains(query) ||
              source.id.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _submitSelectedSources() async {
    final userEmail =
        UserManager.instance.email; // Retrieve email from UserManager
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email not available')),
      );
      return;
    }

    final url = Uri.parse('http://$ip:40734/save-sources');
    final body = {
      'email': userEmail,
      'selectedSources': selectedSources.toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Navigate to GeneralArticlesScreen with selected sources
        Navigator.pushNamed(context, '/general-articles', arguments: {
          'selectedSources': selectedSources.toList(),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save sources.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your News Sources'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sources',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredSources.length,
              itemBuilder: (context, index) {
                final source = filteredSources[index];
                final isSelected = selectedSources.contains(source.id);
                return SourceCard(
                  source: source,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedSources.remove(source.id);
                      } else {
                        selectedSources.add(source.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed:
                  selectedSources.isNotEmpty ? _submitSelectedSources : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
