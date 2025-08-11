import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();

  bool isGuest = false; // To check if the user is a guest
  bool isUpdating = false;
  String avatarUrl = 'assets/avatars/avatar1.png'; // Default avatar image

  final List<String> avatarImages = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatars/avatar5.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data from SharedPreferences
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      emailController.text = prefs.getString('userEmail') ?? ''; // Email
      isGuest = emailController.text == "guest"; // Check if the user is a guest

      if (!isGuest) {
        usernameController.text = prefs.getString('userName') ?? ''; // Username
        categoryController.text = prefs.getString('userCategory') ??
            'Not Selected'; // Default category
        sourceController.text =
            prefs.getString('userSource') ?? 'Not selected'; // Default source
        avatarUrl = prefs.getString('avatarUrl') ?? avatarImages[0];
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Set isLoggedIn to false

    // Navigate back to the sign-in options page
    Navigator.pushReplacementNamed(context, '/sign-in-options');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isGuest
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Guest users cannot access the profile section.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the sign-up page
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    child: const Text("Sign Up"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the login page
                      Navigator.pushNamed(context, '/google-sign-in');
                    },
                    child: const Text("Log In"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(avatarUrl),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          IconButton(
                            onPressed: () {
                              // Open the dialog to select an avatar
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Select an Avatar'),
                                  content: SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: avatarImages.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              avatarUrl = avatarImages[index];
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: AssetImage(
                                                  avatarImages[index]),
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Username Field
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Category Field
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Source Field
                    TextField(
                      controller: sourceController,
                      decoration: InputDecoration(
                        labelText: 'Source',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.source),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
