import 'package:flutter/material.dart';

class BionicFormatPage extends StatelessWidget {
  final String articleContent;

  const BionicFormatPage({Key? key, required this.articleContent})
      : super(key: key);

  RichText buildBionicFormattedText(String text,
      {TextStyle? normalStyle, TextStyle? boldStyle}) {
    final words = text.split(' '); // Split the article into words
    List<TextSpan> spans = [];

    // Loop through each word and apply the Bionic formatting
    for (var word in words) {
      if (word.isNotEmpty) {
        final splitIndex = (word.length / 2).ceil(); // Split the word in half
        spans.add(
          TextSpan(
            text: word.substring(0, splitIndex), // Bold part
            style: boldStyle ?? const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        spans.add(
          TextSpan(
            text: word.substring(splitIndex) + ' ', // Normal part
            style:
                normalStyle ?? const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Executive Summary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Image.asset(
                  'assets/bionic_bg.png', // Replace with a real image
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Container(
                    color: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: const Text(
                      'Executive Summary',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mission Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bionic Formatted Article',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: buildBionicFormattedText(
                          articleContent,
                          normalStyle: TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                          boldStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
