// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewPage extends StatefulWidget {
//   final String url;

//   const WebViewPage({Key? key, required this.url}) : super(key: key);

//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Ensure platform-specific support
//     WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Article'),
//         backgroundColor: Colors.red,
//       ),
//       body: Stack(
//         children: [
//           WebView(
//             initialUrl: widget.url,
//             javascriptMode: JavascriptMode.unrestricted,
//             onPageFinished: (url) {
//               setState(() {
//                 _isLoading = false;
//               });
//             },
//           ),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
