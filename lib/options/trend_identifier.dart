// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:webview_flutter/webview_flutter.dart';

// class TrendIdentifierPage extends StatefulWidget {
//   final String topic;

//   const TrendIdentifierPage({Key? key, required this.topic}) : super(key: key);

//   @override
//   _TrendIdentifierPageState createState() => _TrendIdentifierPageState();
// }

// class _TrendIdentifierPageState extends State<TrendIdentifierPage> {
//   late WebViewController _webViewController;
//   bool isLoading = true;
//   String errorMessage = '';
//   String htmlContent = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchTrends();
//   }

//   Future<void> fetchTrends() async {
//     final String url =
//         'https://serpapi.com/search.json?engine=google_trends&q=${widget.topic}&data_type=TIMESERIES';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         // Parse the response body as JSON
//         final jsonResponse = json.decode(response.body);
//         // Extract the relevant trends data and format it as HTML
//         htmlContent = prettifyHtml(jsonResponse);
//         setState(() {
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode} - ${response.body}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }

//   String prettifyHtml(Map<String, dynamic> trendsData) {
//     // Generate a prettified HTML representation of the trends data
//     final trendsHtml =
//         StringBuffer('<html><body><h1>Trends for ${widget.topic}</h1>');
//     trendsHtml.write('<ul>');

//     if (trendsData['results'] != null) {
//       for (var trend in trendsData['results']) {
//         trendsHtml.write('<li>${trend['name']}: ${trend['value']}</li>');
//       }
//     } else {
//       trendsHtml.write('<li>No trends available</li>');
//     }

//     trendsHtml.write('</ul></body></html>');
//     return trendsHtml.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trend Identifier'),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : WebView(
//                   initialUrl: Uri.dataFromString(
//                     htmlContent,
//                     mimeType: 'text/html',
//                   ).toString(),
//                   onWebViewCreated: (WebViewController webViewController) {
//                     _webViewController = webViewController;
//                   },
//                 ),
//     );
//   }
// }
