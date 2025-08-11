import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('userEmail') ?? '';

    print('Is user logged in? $isLoggedIn');
    print('User email: $userEmail');

    if (isLoggedIn) {
      // Debugging log to confirm navigation
      print('Navigating to General Articles');
      Navigator.pushReplacementNamed(context, '/general-articles');
    } else {
      // Debugging log to confirm navigation to login screen
      print('Redirecting to login screen...');
      Navigator.pushReplacementNamed(context, '/sign-in-options');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking the user session
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
