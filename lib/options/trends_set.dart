import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TrendsApp());
}

class TrendsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Trends Visualization',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TrendsChartPage(),
    );
  }
}

class TimelineData {
  final String date;
  final int mukeshAmbani;
  final int ratanTata;

  TimelineData(
      {required this.date,
      required this.mukeshAmbani,
      required this.ratanTata});
}

class TrendsChartPage extends StatefulWidget {
  @override
  _TrendsChartPageState createState() => _TrendsChartPageState();
}

class _TrendsChartPageState extends State<TrendsChartPage> {
  late Future<List<TimelineData>> _trendsData;

  @override
  void initState() {
    super.initState();
    _trendsData = fetchTrendsData();
  }

  Future<List<TimelineData>> fetchTrendsData() async {
    final url =
        'https://serpapi.com/search.json?engine=google_trends&q=mukesh+ambani,ratan+tata&data_type=TIMESERIES&api_key=YOUR_API_KEY';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return parseResponse(jsonResponse);
    } else {
      throw Exception('Failed to load trends data');
    }
  }

  List<TimelineData> parseResponse(dynamic response) {
    List<TimelineData> data = [];
    for (var item in response['interest_over_time']['timeline_data']) {
      data.add(TimelineData(
        date: item['date'],
        mukeshAmbani: item['values'][0]['extracted_value'],
        ratanTata: item['values'][1]['extracted_value'],
      ));
    }
    return data;
  }

  LineChartData generateLineChartData(List<TimelineData> data) {
    return LineChartData(
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < data.length) {
                return Text(
                  data[value.toInt()].date.split(' – ')[0],
                  style: TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            data.length,
            (index) =>
                FlSpot(index.toDouble(), data[index].mukeshAmbani.toDouble()),
          ),
          isCurved: true,
          barWidth: 3,
          color: Colors.blue,
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: List.generate(
            data.length,
            (index) =>
                FlSpot(index.toDouble(), data[index].ratanTata.toDouble()),
          ),
          isCurved: true,
          barWidth: 3,
          color: Colors.red,
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Trends')),
      body: FutureBuilder<List<TimelineData>>(
        future: _trendsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(generateLineChartData(snapshot.data!)),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
