import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  String errorMessage = '';

  // Variables for the pie chart data
  double businessValue = 0.0;
  double politicsValue = 0.0;
  double sportsValue = 0.0;

  // Variables for the line chart data
  List<FlSpot> mukeshAmbaniData = [];
  List<FlSpot> ratanTataData = [];

  int touchedIndex = -1;

  List<Color> pieColors = [
    Colors.blue.shade900,
    Colors.blue.shade700,
    Colors.blue.shade500,
  ];

  @override
  void initState() {
    super.initState();
    initializeEmailAndFetchData();
  }

  // Initialize email from SharedPreferences and UserManager
  Future<void> initializeEmailAndFetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch the email from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');

      if (email != null) {
        UserManager.instance.email = email;

        // Fetch data using the email
        await fetchData(email);
      } else {
        setState(() {
          errorMessage = 'No email found in SharedPreferences.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while initializing email: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to fetch the data based on email
  Future<void> fetchData(String? email) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://180.235.121.245:40734/data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          businessValue =
              (int.tryParse(responseData['business'].toString()) ?? 0)
                  .toDouble();
          politicsValue =
              (int.tryParse(responseData['politics'].toString()) ?? 0)
                  .toDouble();
          sportsValue =
              (int.tryParse(responseData['sports'].toString()) ?? 0).toDouble();
        });
      } else {
        setState(() {
          errorMessage = json.decode(response.body)['error'] ??
              'An unknown error occurred';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch data for the line chart
  Future<void> fetchLineChartData(String keywords) async {
    try {
      final response = await http.get(Uri.parse(
          'https://serpapi.com/search.json?engine=google_trends&q=$keywords&data_type=TIMESERIES&api_key=e1f9541f81f75516b2909dfd5194e700e7ad08c305bb00d176f6322044b61c6a'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final timelineData =
            responseData['interest_over_time']['timeline_data'];

        // Take only the last 20 data points
        final last20Data = timelineData.length > 10
            ? timelineData.sublist(timelineData.length - 10)
            : timelineData;

        setState(() {
          mukeshAmbaniData = List<FlSpot>.from(
            last20Data.asMap().entries.map((entry) {
              final value = entry.value['values'][0]['extracted_value'];
              return FlSpot(
                entry.key.toDouble(),
                value is num ? value.toDouble() : 0.0,
              );
            }),
          );

          ratanTataData = List<FlSpot>.from(
            last20Data.asMap().entries.map((entry) {
              final value = entry.value['values'][1]['extracted_value'];
              return FlSpot(
                entry.key.toDouble(),
                value is num ? value.toDouble() : 0.0,
              );
            }),
          );
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch line chart data';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  // Build Pie Chart with updated values
  Widget getPieChartWithLegend() {
    final List<ChartData> donutData = [
      ChartData(name: "Business", value: businessValue, category: "Business"),
      ChartData(name: "Politics", value: politicsValue, category: "Politics"),
      ChartData(name: "Sports", value: sportsValue, category: "Sports"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'News Sources Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxWidth < 600;

            return isPortrait
                ? Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: donutData.asMap().entries.map((entry) {
                              final isTouched = entry.key == touchedIndex;
                              final value = entry.value;
                              final double fontSize = isTouched ? 16 : 14;
                              final double radius = isTouched ? 90 : 80;

                              return PieChartSectionData(
                                color: pieColors[entry.key % pieColors.length],
                                value: value.value,
                                title: '${value.value.toStringAsFixed(1)}',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            centerSpaceRadius: 30,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegend(donutData),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: donutData.asMap().entries.map((entry) {
                                final isTouched = entry.key == touchedIndex;
                                final value = entry.value;
                                final double fontSize = isTouched ? 16 : 14;
                                final double radius = isTouched ? 90 : 80;

                                return PieChartSectionData(
                                  color:
                                      pieColors[entry.key % pieColors.length],
                                  value: value.value,
                                  title: '${value.value.toStringAsFixed(1)}%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildLegend(donutData),
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buildLegend(List<ChartData> donutData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: donutData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: pieColors[donutData.indexOf(data) % pieColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Build Line Chart
  Widget getLineChart() {
    final TextEditingController keywordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Google Trends Interest Over Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: keywordController,
          decoration: InputDecoration(
            labelText: 'Enter keywords (comma-separated)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final keywords = keywordController.text.trim().replaceAll(' ', '+');
            if (keywords.isNotEmpty) {
              fetchLineChartData(
                  keywords); // Trigger the API fetch with user keywords
            }
          },
          child: const Text('Fetch Data'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: mukeshAmbaniData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: ratanTataData,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
              ],
              // if (errorMessage.isNotEmpty) ...[
              //   Text(errorMessage, style: TextStyle(color: Colors.red)),
              //   const SizedBox(height: 16),
              // ],
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: getPieChartWithLegend(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: getLineChart(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ChartData class
class ChartData {
  final String name;
  final double value;
  final String category;

  ChartData({required this.name, required this.value, required this.category});
}
