import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Article Classifier',
        theme: ThemeData(primarySwatch: Colors.blue));
  }
}

class ArticleClassifierPage extends StatefulWidget {
  final String article;

  const ArticleClassifierPage({Key? key, required this.article})
      : super(key: key);

  @override
  State<ArticleClassifierPage> createState() => _ArticleClassifierPageState();
}

class _ArticleClassifierPageState extends State<ArticleClassifierPage> {
  bool isLoading = false;
  String classification = '';
  String explanation = '';
  double gaugeValue = 0.5;

  @override
  void initState() {
    super.initState();
    classifyArticle(widget.article);
  }

  Future<void> classifyArticle(String article) async {
    setState(() {
      isLoading = true;
      classification = '';
      explanation = '';
    });

    try {
      final response = await http.post(
        Uri.parse("http://180.235.121.245:40734/analyze_article2"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'article': article}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          classification = responseData['classification'] ?? 'Unknown';
          explanation =
              responseData['explanation'] ?? 'No explanation provided';

          if (classification == 'left') {
            gaugeValue = 0.0;
          } else if (classification == 'center') {
            gaugeValue = 0.5;
          } else if (classification == 'right') {
            gaugeValue = 1.0;
          }
        });
      } else {
        setState(() {
          classification = 'Error';
          explanation = 'Failed to fetch classification from backend';
        });
      }
    } catch (e) {
      setState(() {
        classification = 'Error';
        explanation = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildGauge() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Political Classification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 1,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 0.33,
                      color: Colors.red,
                      label: 'Left',
                    ),
                    GaugeRange(
                      startValue: 0.33,
                      endValue: 0.66,
                      color: Colors.blue,
                      label: 'Center',
                    ),
                    GaugeRange(
                      startValue: 0.66,
                      endValue: 1,
                      color: Colors.green,
                      label: 'Right',
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: gaugeValue,
                      enableAnimation: true,
                      needleColor: Colors.black,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        classification.isNotEmpty
                            ? classification.toUpperCase()
                            : 'Waiting...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0.8,
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

  Widget _buildExplanationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explanation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: const TextStyle(fontSize: 16),
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
        title: const Text('Article Classifier'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBBDEFB), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildGauge(),
                    const SizedBox(height: 16),
                    _buildExplanationCard(),
                  ],
                ),
              ),
            ),
    );
  }
}
