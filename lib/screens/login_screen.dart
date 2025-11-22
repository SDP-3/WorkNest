import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'registration_screen.dart';
import 'job_seeker_home_page.dart';
import 'employer_home_page.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String userType = 'jobSeeker';

  // --- আপডেট করা লগইন ফাংশন ---
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ১. Firebase Authentication দিয়ে লগইন (Admin, Employer, Seeker সবার জন্য একই)
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // ২. ডাটাবেস থেকে ইউজারের তথ্য আনা
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          throw Exception("User profile not found in Database!");
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String actualUserType = userData['userType'] ?? 'jobSeeker';

        // ৩. রেডিও বাটন সিলেকশন এবং আসল ডাটাবেস রোলের মধ্যে মিল আছে কিনা চেক করা
        if (userType != actualUserType) {
          await FirebaseAuth.instance.signOut(); // মিল না থাকলে লগআউট করে দেওয়া
          throw Exception("Account type mismatch! You are registered as $actualUserType.");
        }

        // ৪. সঠিক ড্যাশবোর্ডে পাঠানো
        if (mounted) {
          if (actualUserType == 'admin') {
            // --> Admin Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else if (actualUserType == 'employer') {
            // --> Employer Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EmployerHomePage(
                      userData: userData
                          .map((k, v) => MapEntry(k, v.toString())))),
            );
          } else {
            // --> Job Seeker Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      JobSeekerHomePage(email: userData['email'])),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = "Login Failed";
        if (e.code == 'user-not-found') {
          message = "No user found with this email.";
        } else if (e.code == 'wrong-password') {
          message = "Incorrect password.";
        } else if (e.code == 'invalid-credential') {
          message = "Invalid email or password.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/WN_logo.png",
                      width: 250, height: 250),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please enter your email";
                      if (!value.contains('@')) return "Enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please enter your password";
                      if (value.length < 6)
                        return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'jobSeeker',
                          groupValue: userType,
                          onChanged: (value) =>
                              setState(() => userType = value!),
                          activeColor: Colors.blue[900],
                        ),
                        const Text('Job Seeker',
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 10),
                        Radio<String>(
                          value: 'employer',
                          groupValue: userType,
                          onChanged: (value) =>
                              setState(() => userType = value!),
                          activeColor: Colors.blue[900],
                        ),
                        const Text('Employer',
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 10),
                        Radio<String>(
                          value: 'admin',
                          groupValue: userType,
                          onChanged: (value) =>
                              setState(() => userType = value!),
                          activeColor: Colors.redAccent,
                        ),
                        const Text('Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Check your email for the password reset link!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ?? "Error occurred"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "Enter your email to receive a reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter registered email",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter your email";
                    if (!value.contains('@')) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Reset Link",
                          style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






