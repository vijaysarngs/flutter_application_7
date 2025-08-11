import 'package:flutter/material.dart';
import 'package:beyondheadlines/utils/api_service.dart';
import 'package:beyondheadlines/widgets/custom_button.dart';
import 'package:beyondheadlines/utils/otp_sender.dart';

class EmailInputPage extends StatelessWidget {
  final String? previousEmail;

  const EmailInputPage({Key? key, this.previousEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController =
        TextEditingController(text: previousEmail ?? "");

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("Enter Email"),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Add Image at the top
              Image.asset(
                'assets/mailpost.jpg', // Update the path with your image asset
                height: 150, // Adjust the height as needed
              ),
              const SizedBox(
                  height: 20), // Space between the image and the form

              // Email input form section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.blue),
                      hintText: "Enter your email",
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Send OTP",
                onPressed: () async {
                  final email = emailController.text.trim();
                  final response = await ApiService.sendOtp(email);

                  if (response == "OTP sent successfully") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPVerificationPage(email: email),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
