import 'package:flutter/material.dart';
import 'dart:async';
import 'package:beyondheadlines/onboard/root.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToRoot(); // Navigate to the root screen after 5 seconds
  }

  void _navigateToRoot() {
    Timer(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF4500), // Vibrant orange-red
              Color(0xFF1E90FF), // Deep blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Globe-like icon with vibrant colors
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                      Colors.blue,
                    ],
                    center: Alignment.center,
                    radius: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.public, // Replace with a globe-like icon
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // App name
              const Text(
                'Beyond Headlines',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              const Text(
                'Stay Informed, Stay Ahead',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
