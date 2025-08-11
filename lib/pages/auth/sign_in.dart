// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'package:beyondheadlines/pages/auth/discover.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _sourceController = TextEditingController();

//   static const String baseUrl = "http://192.168.91.128:40735/signup2";

//   Future<void> _handleSignUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final response = await http
//           .post(
//         Uri.parse(baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text.trim(),
//           'category': _categoryController.text.trim(),
//           'source': _sourceController.text.trim(),
//         }),
//       )
//           .timeout(const Duration(seconds: 20), onTimeout: () {
//         throw TimeoutException('Connection timed out');
//       });

//       if (response.statusCode == 201) {
//         // Navigate directly to the Discover page
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const DiscoverScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Signup failed: Unknown error')),
//         );
//       }
//     } catch (e, stackTrace) {
//       print('Error: $e');
//       print('StackTrace: $stackTrace');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Signup failed: $e'),
//           backgroundColor: Colors.yellow,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("Sign Up"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Create\nan Account",
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 32),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   hintText: 'Name',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: const Icon(Icons.person_outline),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   hintText: 'Email',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: const Icon(Icons.email_outlined),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter your email';
//                   }
//                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                       .hasMatch(value)) {
//                     return 'Enter a valid email';
//                   }
//                   return '';
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: !_isPasswordVisible,
//                 decoration: InputDecoration(
//                   hintText: 'Password',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () => setState(
//                         () => _isPasswordVisible = !_isPasswordVisible),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter a password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return '';
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _categoryController,
//                 decoration: InputDecoration(
//                   hintText: 'Category',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: const Icon(Icons.category_outlined),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _sourceController,
//                 decoration: InputDecoration(
//                   hintText: 'Source',
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: const Icon(Icons.source_outlined),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleSignUp,
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text('Sign Up'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
