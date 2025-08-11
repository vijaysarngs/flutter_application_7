// import 'package:flutter/material.dart';
// import 'package:beyondheadlines/utils/user_manager.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class FeedbackPage extends StatefulWidget {
//   const FeedbackPage({super.key});

//   @override
//   State<FeedbackPage> createState() => _FeedbackPageState();
// }

// class _FeedbackPageState extends State<FeedbackPage> {
//   num _rating = 3; // Default rating is 3
//   String _review = '';
//   bool _isSubmitting = false;

//   Future<void> _submitFeedback() async {
//     final ip = UserManager.instance.ipCurrent;
//     final email = UserManager.instance.email;

//     if (ip == null || ip.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Server IP is not configured!')),
//       );
//       return;
//     }
//     if (email == null || email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Email is not set in UserManager!')),
//       );
//       return;
//     }

//     FocusScope.of(context).unfocus(); // Dismiss keyboard
//     setState(() => _isSubmitting = true);

//     try {
//       final body = json.encode({
//         'email': email,
//         'review': _review,
//         'rating': _rating,
//       });

//       print('Request body: $body'); // Debug log

//       final response = await http.post(
//         Uri.parse('http://$ip:40735/submit_feedback'),
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         try {
//           final result = json.decode(response.body);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['message'] ?? 'Feedback submitted!')),
//           );
//         } catch (error) {
//           print('JSON decoding error: $error');
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Invalid response from the server.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to submit feedback: ${response.body}')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $error')),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           true, // This ensures the UI adjusts when the keyboard appears
//       appBar: AppBar(title: const Text('Feedback')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8.0,
//               children: List.generate(5, (index) {
//                 Color starColor = _rating >= index + 1
//                     ? Colors.blue.shade700
//                     : Colors.blue.shade300;
//                 return IconButton(
//                   icon: Icon(
//                     index < _rating ? Icons.star : Icons.star_border,
//                     color: starColor,
//                     size: 40,
//                   ),
//                   onPressed: () => setState(() {
//                     _rating = (index + 1).clamp(1, 5);
//                   }),
//                 );
//               }),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 labelText: 'What feature can we add to improve ourselves?',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) => _review = value,
//             ),
//             const SizedBox(height: 20),
//             _isSubmitting
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _submitFeedback,
//                     child: const Text('SEND FEEDBACK'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blue,
//                       textStyle: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
