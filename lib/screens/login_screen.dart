
import 'package:flutter/material.dart';

import 'registration_screen.dart'; 
import 'job_seeker_home_page.dart'; 
import 'employer_home_page.dart'; 

// ---------------------- LOGIN SCREEN ----------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String userType = 'jobSeeker'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                Image.asset("assets/images/WN_logo.png", width: 250, height: 250),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Email or Phone",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.emailAddress, // Added keyboard type
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true, // Hides password
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'jobSeeker',
                      groupValue: userType, // Tracks the selected value
                      onChanged: (value) {
                        setState(() {
                          userType = value!; // Updates state on change
                        });
                      },
                      activeColor: Colors.blue[900], // Color when selected
                    ),
                    const Text('Job Seeker', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'employer',
                      groupValue: userType, // Tracks the selected value
                      onChanged: (value) {
                        setState(() {
                          userType = value!; // Updates state on change
                        });
                      },
                      activeColor: Colors.blue[900], // Color when selected
                    ),
                    const Text('Employer', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 🔹 --- START: DUMMY LOGIN LOGIC ---
                    // This is temporary for testing before backend implementation
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (userType == 'jobSeeker' && email == "seeker@test.com" && password == "1234") {
                      // Login as Job Seeker
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobSeekerHomePage(
                            email: email, // Pass email as per original structure
                          ),
                        ),
                      );
                    } else if (userType == 'employer' && email == "employer@test.com" && password == "1234") {
                      // Login as Employer
                      Map<String, String> dummyEmployerData = {
                        "name": "Test Employer Inc.",
                        "email": email,
                        "phone": "0123456789",
                        "father": "Mr. Employer",
                        "presentAddress": "Dhaka",
                        "permanentAddress": "Dhaka",
                        "nid": "1234567890",
                        "userType": "employer",
                        "gender": "Other",
                        "location": "Lat: 23.8103, Long: 90.4125"
                        // Add imagePath if needed: "imagePath": "path/to/dummy/image.png"
                      };

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployerHomePage(
                            userData: dummyEmployerData, // Pass dummy data to Employer home
                          ),
                        ),
                      );
                    } else {
                      // Incorrect credentials
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid test credentials. Use 'seeker@test.com' or 'employer@test.com' and password '1234'")),
                      );
                    }
                    // 🔹 --- END: DUMMY LOGIN LOGIC ---
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: const Size(double.infinity, 50), // Full width button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                // Forgot Password Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordRecoveryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Colors.black, // Changed color for visibility
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Registration Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(), // 'onRegister' is removed
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.black), // Changed color for visibility
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Password Recovery Screen (remains the same)
class PasswordRecoveryScreen extends StatelessWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Recovery"),
        backgroundColor: Colors.blue[900], // Added consistent app bar color
        foregroundColor: Colors.white, // Added text color for app bar
      ),
      body: const Center(
        child: Text("Password recovery screen coming soon..."),
      ),
    );
  }
}