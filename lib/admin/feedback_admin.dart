import 'package:flutter/material.dart';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FeedbackTable(),
    );
  }
}

class FeedbackTable extends StatefulWidget {
  @override
  _FeedbackTableState createState() => _FeedbackTableState();
}

class _FeedbackTableState extends State<FeedbackTable> {
  List feedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    String? useremail = UserManager.instance.email;
    final response = await http.get(
        Uri.parse('http://180.235.121.245:40735/feedbacks?email=$useremail'));
    if (response.statusCode == 200) {
      setState(() {
        feedbacks = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load feedbacks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: feedbacks.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Rating')),
                          DataColumn(label: Text('Review')),
                          DataColumn(label: Text('Created At')),
                        ],
                        rows: feedbacks.map((feedback) {
                          return DataRow(cells: [
                            DataCell(Text(feedback['id'].toString())),
                            DataCell(Text(feedback['email'])),
                            DataCell(Text(feedback['rating'].toString())),
                            DataCell(Text(feedback['review'])),
                            DataCell(Text(feedback['created_at'])),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
