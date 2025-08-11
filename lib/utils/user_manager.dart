import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // Private constructor
  UserManager._privateConstructor();

  // Singleton instance
  static final UserManager instance = UserManager._privateConstructor();

  // Map to store article counts per category for each email
  static final Map<String, UserManager> _instances = {};

  static String? _currentUserEmail;
  String? ipCurrent = "180.235.121.245";
  String? email; // Primary property for user identification
  String? msg;

  // Map to track the article count per category for each user
  Map<String, int> articleCountByCategory = {};
  int totalArticlesRead = 0;

  // Proportions for each category
  double businessProportion = 33.0;
  double politicsProportion = 33.0;
  double sportsProportion = 33.0;

  // Private constructor for initializing user data
  UserManager._(this.email);

  // Factory method to retrieve or create UserManager instance based on the email
  factory UserManager(String email) {
    if (!_instances.containsKey(email)) {
      // Create a fresh instance for this email if not already present
      _instances[email] = UserManager._(email);
    }
    return _instances[email]!;
  }

  // Set the current user email
  static void setCurrentUserEmail(String email) {
    _currentUserEmail = email;
  }

  // Getter to retrieve the current user's email
  static String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  String? iot;
  // Function to assign email from SharedPreferences
  Future<void> initializeEmailFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    iot = prefs.getString('userEmail');
    if (iot != null) {
      email = iot;
    } else {
      throw Exception('Email not found in SharedPreferences.');
    }
  }

  // Function to increment article count for a specific category
  void incrementCategoryCount(String category) {
    if (articleCountByCategory.containsKey(category)) {
      articleCountByCategory[category] = articleCountByCategory[category]! + 1;
    } else {
      articleCountByCategory[category] = 1;
    }
    totalArticlesRead++;
  }

  // Get the count of articles for a specific category
  int getCategoryCount(String category) {
    return articleCountByCategory[category] ?? 0;
  }

  // Get the total count of articles read by this user
  int getTotalArticlesRead() {
    return totalArticlesRead;
  }
}
