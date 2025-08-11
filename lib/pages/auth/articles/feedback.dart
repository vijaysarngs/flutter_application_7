import 'package:flutter/material.dart';
import 'package:beyondheadlines/utils/user_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String? ip = UserManager.instance.ipCurrent;

class FeedbackPage2 extends StatefulWidget {
  const FeedbackPage2({super.key});

  @override
  State<FeedbackPage2> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage2> {
  double _rating = 3.0; // Start at the 3rd value
  String _review = '';
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    if (ip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server IP is not configured!')),
      );
      return;
    }

    if (email == null || email.isEmpty || email == "guest") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Login Required"),
            content: const Text("Please log in or sign up to submit feedback."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to Login or Signup screen
                  // Example: Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login/Sign Up"),
              ),
            ],
          );
        },
      );
      return;
    }

    FocusScope.of(context).unfocus(); // Dismiss keyboard
    setState(() => _isSubmitting = true);

    try {
      final body = json.encode({
        'email': email,
        'rating': _rating,
        'review': _review,
      });

      final response = await http.post(
        Uri.parse('http://$ip:40735/submit_feedback'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Feedback submitted!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit feedback: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Rate Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                Color starColor = _rating >= index + 1
                    ? Colors.blue.shade700
                    : Colors.blue.shade300;
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: starColor,
                    size: 40,
                  ),
                  onPressed: () => setState(() {
                    _rating = index + 1.0;
                  }),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What feature can we add to improve?',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _review = value,
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('SEND FEEDBACK'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
