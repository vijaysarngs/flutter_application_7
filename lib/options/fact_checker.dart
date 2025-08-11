import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beyondheadlines/utils/user_manager.dart';

String? ip = UserManager.instance.ipCurrent;

class FactCheckerPage extends StatefulWidget {
  final String sourceName;
  final String articleUrl;
  final String articleContent;

  const FactCheckerPage(
      {Key? key,
      required this.sourceName,
      required this.articleUrl,
      required this.articleContent})
      : super(key: key);

  @override
  State<FactCheckerPage> createState() => _FactCheckerPageState();
}

class _FactCheckerPageState extends State<FactCheckerPage> {
  double polarityScore = 50;
  double subjectivityScore = 50;
  bool isLoading = true;
  bool showResults = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      fetchSentimentDataFromAPI(widget.articleContent);
    });
  }

  Future<void> fetchSentimentDataFromAPI(String article) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final String apiUrl = "http://$ip:40734/analyze_sentiment";
      final response = await http
          .post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'article': article}),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          polarityScore = data['polarity'] ?? 50;
          subjectivityScore = data['subjectivity'] ?? 50;
          isLoading = false;
          showResults = true;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data from the backend';
          showResults = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        showResults = false;
      });
    }
  }

  void showAnalysisDefinitionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Polarity & Subjectivity Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: const Text(
            'Polarity analysis determines the sentiment orientation of text, '
            'ranging from negative to positive. It helps identify whether the '
            'content conveys criticism, support, or neutrality. Subjectivity '
            'analysis evaluates the extent of opinion versus factual content, '
            'indicating whether an article is based on personal views or objective data.\n\n'
            'In the context of news media, understanding polarity and subjectivity '
            'is critical for detecting biases, ensuring balanced reporting, and promoting '
            'media literacy among readers.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolarityGauge() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Polarity Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: -1,
                  maximum: 1,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: -1,
                      endValue: -0.5,
                      color: Colors.red,
                      label: 'Negative',
                    ),
                    GaugeRange(
                      startValue: -0.5,
                      endValue: 0.5,
                      color: Colors.orange,
                      label: 'Neutral',
                    ),
                    GaugeRange(
                      startValue: 0.5,
                      endValue: 1,
                      color: Colors.green,
                      label: 'Positive',
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: polarityScore,
                      enableAnimation: true,
                      needleColor: Colors.black,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "Polarity: ${polarityScore.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0.75,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectivityGauge() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Subjectivity Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 1,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 0.5,
                      color: Colors.green,
                      label: 'Objective',
                    ),
                    GaugeRange(
                      startValue: 0.5,
                      endValue: 1,
                      color: Colors.red,
                      label: 'Subjective',
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: subjectivityScore,
                      enableAnimation: true,
                      needleColor: Colors.black,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "Subjectivity: ${subjectivityScore.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0.75,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: showAnalysisDefinitionDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBBDEFB), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : showResults
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildPolarityGauge(),
                          const SizedBox(height: 16),
                          _buildSubjectivityGauge(),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
      ),
    );
  }
}
