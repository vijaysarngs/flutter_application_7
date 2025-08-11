import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummarizePage extends StatefulWidget {
  final String articleUrl;

  const SummarizePage({Key? key, required this.articleUrl}) : super(key: key);

  @override
  State<SummarizePage> createState() => _SummarizePageState();
}

class _SummarizePageState extends State<SummarizePage> {
  String? summary;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSummary(widget.articleUrl);
  }

  Future<void> fetchSummary(String url) async {
    const apiUrl =
        "https://article-extractor-and-summarizer.p.rapidapi.com/summarize";
    const headers = {
      "x-rapidapi-host": "article-extractor-and-summarizer.p.rapidapi.com",
      "x-rapidapi-key": "115d00385amsh0802c13ef4bc336p152281jsne2a7e092e9e1",
    };

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?url=$url&lang=en&engine=2'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          summary = data['summary'] ?? 'No summary available';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch summary: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Summary'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Article Summary',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'URL: ${widget.articleUrl}',
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          summary ?? 'No summary available',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
