import 'package:flutter/material.dart';
import 'package:beyondheadlines/admin/feedback_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin User Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/user-data',
      routes: {
        '/user-data': (context) => const UserTablePage(),
        '/admin-feedback': (context) =>
            FeedbackTable(), // Map to FeedbackTable widget
      },
    );
  }
}

class UserTablePage extends StatefulWidget {
  const UserTablePage({super.key});

  @override
  State<UserTablePage> createState() => _UserTablePageState();
}

class _UserTablePageState extends State<UserTablePage> {
  List<Map<String, dynamic>> users = [];
  String errorMessage = '';
  bool isLoading = false;

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://180.235.121.245:40734/users'), // Replace with backend endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        setState(() {
          errorMessage =
              json.decode(response.body)['error'] ?? 'Failed to fetch users';
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

  Future<void> deleteUser(String email) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://180.235.121.245:40734/users/$email'), // Replace with backend endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          users.removeWhere((user) => user['email'] == email);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin User Management'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User Data'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/user-data');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedbacks'),
              onTap: () {
                // Navigate to FeedbackTable directly without using named route
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackTable()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red)))
                : users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            color: Colors.white, // White background for table
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Source')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: users
                                  .map(
                                    (user) => DataRow(
                                      cells: [
                                        DataCell(Text(user['name'])),
                                        DataCell(Text(user['email'])),
                                        DataCell(Text(user['category'])),
                                        DataCell(Text(user['source'])),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                deleteUser(user['email']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
      ),
    );
  }
}
