import 'package:flutter/material.dart';
import 'package:beyondheadlines/admin/feedback_admin.dart';
import 'package:beyondheadlines/onboard/root.dart';
import 'package:beyondheadlines/onboard/splashscren.dart';
import 'package:beyondheadlines/options/doom.dart';
// import 'package:beyondheadlines/onboard/edit_profile.dart';
import 'package:beyondheadlines/pages/auth/articles/edit_profile.dart';
import 'package:beyondheadlines/pages/auth/articles/feedback.dart';
import 'package:beyondheadlines/pages/auth/articles/profile_view.dart';
import 'package:beyondheadlines/pages/auth/sign_up.dart';
import '/onboard/onboard.dart';
import 'pages/auth/sign_in_option.dart';
// import 'pages/auth/sign_in.dart';
import 'pages/auth/google_sign_in.dart';
import 'pages/auth/discover.dart';
import 'pages/auth/source_selction.dart';
// import 'pages/auth/news_filter.dart';
import 'pages/auth/articles/general_article.dart';
// import 'pages/auth/articles/article_detail.dart';
import 'package:beyondheadlines/pages/auth/articles/dashboard.dart';
import 'package:beyondheadlines/admin/userpage.dart';
import 'package:beyondheadlines/pages/auth/articles/otp_screen.dart';
import 'package:beyondheadlines/onboard/forgot_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beyond Headlines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/sign-in-options': (context) => const SignInOptionsScreen(),
        '/onboard': (context) => const OnboardingScreen(),
        '/profile': (context) => const ProfilePage(),
        '/sign-up': (context) => const SignUpScreen(),
        '/google-sign-in': (context) => const SignInScreen(),
        '/discover': (context) => const DiscoverScreen(),
        '/source-selection': (context) => const SourceSelectionScreen(),
        '/general-articles': (context) => const GeneralArticlesScreen(),
        '/feedback': (context) => const FeedbackPage2(),
        '/dashboard': (context) => const DashboardPage(),
        '/edit-profile': (context) => const EditProfileApp(),
        '/admin-dashboard': (context) => const UserTablePage(),
        // '/feedbacks': (context) => const FeedbackPage(),
        '/admin-feedback': (context) => FeedbackTable(),
        '/otp': (context) => const EmailInputPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/doom-scroll': (context) => DoomScrollPage()
      },
    );
  }
}
