import 'package:flutter/material.dart';
import 'onboard_content.dart';
import 'onboard_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      image: 'assets/protest.jpg',
      title: 'Get the latest\nnews from\nreliable\nsources.',
      buttonText: 'Next',
    ),
    OnboardingContent(
      image: 'assets/protest.jpg',
      title: 'Get the latest\nnews from\nreliable\nsources.',
      buttonText: 'Next',
    ),
    OnboardingContent(
      image: 'assets/flags.jpg',
      title: 'Still up to date\nnews from all\naround the\nworld',
      buttonText: 'Next',
    ),
    OnboardingContent(
      image: 'assets/capitol.jpg',
      title: 'From art to\npolitics,\nanything in\nNewzia.',
      buttonText: 'Sign In',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                content: _pages[index],
                pageController: _pageController,
                isLastPage: index == _pages.length - 1,
              );
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/sign-in-options');
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
