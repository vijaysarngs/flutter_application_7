import 'package:flutter/material.dart';
import 'package:beyondheadlines/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SignInOptionsScreen extends StatefulWidget {
  const SignInOptionsScreen({Key? key}) : super(key: key);

  @override
  _SignInOptionsScreenState createState() => _SignInOptionsScreenState();
}

class _SignInOptionsScreenState extends State<SignInOptionsScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Design
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6F7FF), Color(0xFFCCE7F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -60,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(150),
                ),
              ),
            ),
          ),
          // Content Layer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // More rounded
                    child: Image.asset(
                      'assets/bhnewlogo.png',
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Sign In Button
                CustomButton(
                  text: 'Sign In with Email',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/google-sign-in'),
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  icon: Image.asset('assets/google_icon.jpg', height: 24),
                ),
                const SizedBox(height: 16),

                // Guest Login Button
                CustomButton(
                  text: 'Continue as Guest',
                  onPressed: _handleGuestLogin,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  icon: const Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(height: 30),

                // Reviews Section Header
                const Text(
                  "What Our Users Say",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Reviews Section
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), // Slightly rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          children: [
                            _buildReview(
                              username: 'vijay321',
                              rating: 5,
                              comment:
                                  'Great app! Very easy to use and intuitive.',
                            ),
                            _buildReview(
                              username: 'palani654',
                              rating: 5,
                              comment: 'Love it! Perfect for reading articles.',
                            ),
                            _buildReview(
                              username: 'wesley789',
                              rating: 5,
                              comment:
                                  'A must-have app for anyone looking to stay updated.',
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: WormEffect(
                            dotColor: Colors.grey,
                            activeDotColor: Colors.red,
                            radius: 8,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Sign Up Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handles Guest Login and sets SharedPreferences
  Future<void> _handleGuestLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', 'guest');
    Navigator.pushReplacementNamed(context, '/general-articles');
  }

  Widget _buildReview({
    required String username,
    required int rating,
    required String comment,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Slightly rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                rating,
                (index) =>
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
