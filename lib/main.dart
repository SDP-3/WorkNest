// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


// ----------------- GLOBAL REGISTERED USERS -----------------
List<Map<String, String>> registeredUsers = []; 

void main() {
  runApp(const WorkNestApp());
}

class WorkNestApp extends StatelessWidget {
  const WorkNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

// ---------------------- SPLASH SCREEN ----------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _worknestController;
  late AnimationController _subtitleController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _worknestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      _subtitleController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _worknestController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
              ),
              child: Image.asset(
                "assets/images/WN_logo.png",
                width: 400,
                height: 400,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _worknestController,
              child: Text(
                "WorkNest",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _subtitleController,
              child: Text(
                "A career and job finding platform",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(239, 6, 6, 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
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
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value!;
                        });
                      },
                    ),
                    const Text('Job Seeker', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'employer',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value!;
                        });
                      },
                    ),
                    const Text('Employer', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String input = emailController.text.trim();
                    String password = passwordController.text.trim();
                    bool found = false;

                    for (var user in registeredUsers) {
                      if ((user['email'] == input || user['phone'] == input) && user['password'] == password) {
                        found = true;

                        if (userType == user['userType']) {
                          if (userType == 'jobSeeker') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobSeekerHomePage(
                                  email: user['email']!,
                                ),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployerHomePage(
                                  userData: user, // ✅ Fix: userData পাঠানো
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Selected user type does not match registration")),
                          );
                        }
                        break;
                      }
                    }

                    if (!found) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid email/phone or password")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),

                // 🔹 Added "Forgot Password?" text button
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // এখানে তুমি চাও তো PasswordRecoveryScreen() এ নিতে পারো
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
                        builder: (context) => RegistrationScreen(
                          onRegister: (newUser) {
                            registeredUsers.add(newUser);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordRecoveryScreen extends StatelessWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password Recovery")),
      body: const Center(
        child: Text("Password recovery screen coming soon..."),
      ),
    );
  }
}

// ---------------------- JOB SEEKER HOME PAGE ----------------------

class JobSeekerHomePage extends StatelessWidget {
  final String email;
  const JobSeekerHomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        "HOME",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color:  Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.blue),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  "3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // ------------------ Job Seeker Label ------------------
              const Text(
                "Job Seeker",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20), // spacing before grid
              
              // ------------------ Grid ------------------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: [
                    _gridItem(
                      context,
                      Icons.person,
                      "Profile",
                      () {
                        Map<String, String> userData = registeredUsers.firstWhere(
                          (user) => user['email'] == email,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobSeekerProfilePage(
                              userData: userData,
                              onUpdate: (updatedUser) {
                                int index = registeredUsers.indexWhere((user) => user['email'] == email);
                                if (index != -1) {
                                  registeredUsers[index] = updatedUser;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _gridItem(context, Icons.work, "Job Board", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JobBoardPage()),
                      );
                    }),
                    _gridItem(context, Icons.assignment_turned_in, "Applied Jobs", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppliedJobsPage()),
                      );
                    }),
                    _gridItem(context, Icons.support_agent, "Customer Care", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerCarePage()),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue[900]),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- EMPLOYER HOME PAGE ----------------------

class EmployerHomePage extends StatelessWidget {
  final Map<String, String> userData; // Registration থেকে আসা info
  const EmployerHomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // ------- Top bar -------
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blue[900], 
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        "HOME",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: Colors.blue),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  "3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------ Employer Label ------------------
              const Text(
                "Employer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20), // spacing before grid

              // ------------------ Grid items ------------------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: [
                    _gridItem(
                      context,
                      Icons.person,
                      "Profile",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployerProfilePage(
                              userData: userData,
                              onUpdate: (updatedUser) {},
                            ),
                          ),
                        );
                      },
                    ),
                    _gridItem(
                      context,
                      Icons.post_add,
                      "Post Job",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostJobPage(employerData: userData),
                          ),
                        );
                      },
                    ),
                    _gridItem(
                      context,
                      Icons.assignment,
                      "Job Applications",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobApplicationsPage(),
                          ),
                        );
                      },
                    ),
                    _gridItem(
                      context,
                      Icons.support_agent,
                      "Customer Care",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerCarePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------- Logout button -------
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blue[900]),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- REGISTRATION SCREEN ----------------------
class RegistrationScreen extends StatefulWidget {
  final Function(Map<String, String>) onRegister;
  const RegistrationScreen({super.key, required this.onRegister});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  File? _image;
  String _location = "";
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController presentAddressController = TextEditingController();
  final TextEditingController permanentAddressController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String userType = "";
  String gender = "";

  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Icon(Icons.person, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  InputDecoration _inputDecorationDropdown(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
    );
  }

  void _registerUser() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String email = emailController.text.trim();

    if (nameController.text.trim().isEmpty || email.isEmpty || phoneController.text.trim().isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (userType.isEmpty || gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select User Type and Gender")));
      return;
    }

    bool exists = registeredUsers.any((user) => user['email'] == email || user['phone'] == phoneController.text.trim());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email or Phone already registered")));
      return;
    }

    Map<String, String> newUser = {
      "name": nameController.text.trim(),
      "email": email,
      "phone": phoneController.text.trim(),
      "father": fatherController.text.trim(),
      "presentAddress": presentAddressController.text.trim(),
      "permanentAddress": permanentAddressController.text.trim(),
      "nid": nidController.text.trim(),
      "password": password,
      "userType": userType,
      "gender": gender,
      "location": _location,
    };

    widget.onRegister(newUser);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful")));

    // Navigate to home page based on user type
    if (userType == 'employer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmployerHomePage(userData: newUser)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => JobSeekerHomePage(email: newUser['email']!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI unchanged, just _registerUser updated
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: _inputDecoration("Name")),
              const SizedBox(height: 15),
              TextField(controller: emailController, decoration: _inputDecoration("Email")),
              const SizedBox(height: 15),
              TextField(controller: phoneController, decoration: _inputDecoration("Phone")),
              const SizedBox(height: 15),
              TextField(controller: fatherController, decoration: _inputDecoration("Father Name")),
              const SizedBox(height: 15),
              TextField(controller: presentAddressController, decoration: _inputDecoration("Present Address")),
              const SizedBox(height: 15),
              TextField(controller: permanentAddressController, decoration: _inputDecoration("Permanent Address")),
              const SizedBox(height: 15),
              TextField(controller: nidController, decoration: _inputDecoration("NID")),
              const SizedBox(height: 15),
              TextField(controller: passwordController, obscureText: true, decoration: _inputDecoration("Password")),
              const SizedBox(height: 15),
              TextField(controller: confirmPasswordController, obscureText: true, decoration: _inputDecoration("Confirm Password")),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: userType.isEmpty ? null : userType,
                items: const [
                  DropdownMenuItem(value: "jobSeeker", child: Text("Job Seeker")),
                  DropdownMenuItem(value: "employer", child: Text("Employer")),
                ],
                onChanged: (value) { setState(() { userType = value!; }); },
                decoration: _inputDecorationDropdown("Select User Type"),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: gender.isEmpty ? null : gender,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) { setState(() { gender = value!; }); },
                decoration: _inputDecorationDropdown("Select Gender"),
              ),
              const SizedBox(height: 15),
              ElevatedButton(onPressed: getUserLocation, child: const Text("Get Location")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text("Register"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------- EMPLOYER PROFILE PAGE (Gender Dropdown Only Editable) ---------------------------

class EmployerProfilePage extends StatefulWidget {
  final Map<String, String> userData;
  final Function(Map<String, String>) onUpdate;

  const EmployerProfilePage({
    super.key,
    required this.userData,
    required this.onUpdate,
  });

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage> {
  late Map<String, String> user;
  bool isEditing = false;
  String? selectedGender;
  String? imagePath;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController fatherController;
  late TextEditingController presentAddressController;
  late TextEditingController permanentAddressController;
  late TextEditingController nidController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    user = Map.from(widget.userData);

    nameController = TextEditingController(text: user['name']);
    emailController = TextEditingController(text: user['email']);
    phoneController = TextEditingController(text: user['phone']);
    fatherController = TextEditingController(text: user['father']);
    presentAddressController = TextEditingController(text: user['presentAddress']);
    permanentAddressController = TextEditingController(text: user['permanentAddress']);
    nidController = TextEditingController(text: user['nid']);
    locationController = TextEditingController(text: user['location']);

    selectedGender = user['gender'];
    imagePath = user['photo'];
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fatherController.dispose();
    presentAddressController.dispose();
    permanentAddressController.dispose();
    nidController.dispose();
    locationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
          const SizedBox(height: 5),
          TextField(controller: controller, enabled: enabled, decoration: _inputDecoration("Enter $label")),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      imagePath = "assets/sample_profile.png";
    });
  }

  void _saveProfile() {
    setState(() {
      user['name'] = nameController.text.trim();
      user['email'] = emailController.text.trim();
      user['phone'] = phoneController.text.trim();
      user['father'] = fatherController.text.trim();
      user['presentAddress'] = presentAddressController.text.trim();
      user['permanentAddress'] = permanentAddressController.text.trim();
      user['nid'] = nidController.text.trim();
      user['location'] = locationController.text.trim();

      if (selectedGender != null && ["Male","Female","Other"].contains(selectedGender)) {
        user['gender'] = selectedGender!;
      }

      user['photo'] = imagePath ?? '';
      isEditing = false;
    });

    widget.onUpdate(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile photo
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: imagePath != null ? AssetImage(imagePath!) : null,
                child: imagePath == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildField("Name", nameController, enabled: isEditing),
                    _buildField("Email", emailController, enabled: isEditing),
                    _buildField("Phone", phoneController, enabled: isEditing),
                    _buildField("Father Name", fatherController, enabled: isEditing),
                    _buildField("Present Address", presentAddressController, enabled: isEditing),
                    _buildField("Permanent Address", permanentAddressController, enabled: isEditing),
                    _buildField("NID", nidController, enabled: isEditing),
                    _buildField("Location", locationController, enabled: isEditing),

                    // User Type (readonly)
                    _buildField("User Type", TextEditingController(text: user['userType']), enabled: false),

                    // Gender dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gender",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedGender != null &&
                                        ["Male","Female","Other"].contains(selectedGender)
                                    ? selectedGender
                                    : null,
                                isExpanded: true,
                                onChanged: isEditing
                                    ? (value) {
                                        setState(() {
                                          selectedGender = value;
                                        });
                                      }
                                    : null,
                                items: const [
                                  DropdownMenuItem(value: "Male", child: Text("Male")),
                                  DropdownMenuItem(value: "Female", child: Text("Female")),
                                  DropdownMenuItem(value: "Other", child: Text("Other")),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(isEditing ? "Save Changes" : "Update Profile", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}


// --------------------------- JOB SEEKER PROFILE PAGE (User Type Readonly, Gender Editable) ---------------------------

class JobSeekerProfilePage extends StatefulWidget {
  final Map<String, String> userData;
  final Function(Map<String, String>) onUpdate;

  const JobSeekerProfilePage({super.key, required this.userData, required this.onUpdate});

  @override
  State<JobSeekerProfilePage> createState() => _JobSeekerProfilePageState();
}

class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
  late Map<String, String> user;
  bool isEditing = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController fatherController;
  late TextEditingController presentAddressController;
  late TextEditingController permanentAddressController;
  late TextEditingController nidController;
  late TextEditingController locationController;

  String userType = "";
  String gender = "";

  @override
  void initState() {
    super.initState();
    user = Map.from(widget.userData);

    nameController = TextEditingController(text: user['name']);
    emailController = TextEditingController(text: user['email']);
    phoneController = TextEditingController(text: user['phone']);
    fatherController = TextEditingController(text: user['father']);
    presentAddressController = TextEditingController(text: user['presentAddress']);
    permanentAddressController = TextEditingController(text: user['permanentAddress']);
    nidController = TextEditingController(text: user['nid']);
    locationController = TextEditingController(text: user['location']);
    userType = user['userType'] ?? '';
    gender = user['gender'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fatherController.dispose();
    presentAddressController.dispose();
    permanentAddressController.dispose();
    nidController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
          const SizedBox(height: 5),
          TextField(controller: controller, enabled: enabled, decoration: _inputDecoration("Enter $label")),
        ],
      ),
    );
  }

  void _saveProfile() {
    setState(() {
      user['name'] = nameController.text.trim();
      user['email'] = emailController.text.trim();
      user['phone'] = phoneController.text.trim();
      user['father'] = fatherController.text.trim();
      user['presentAddress'] = presentAddressController.text.trim();
      user['permanentAddress'] = permanentAddressController.text.trim();
      user['nid'] = nidController.text.trim();
      user['location'] = locationController.text.trim();

      // Only update gender and image
      if (["Male","Female","Other"].contains(gender)) user['gender'] = gender;
      if (_image != null) user['imagePath'] = _image!.path;

      // User type remains readonly
      user['userType'] = userType;

      isEditing = false;
    });

    widget.onUpdate(user);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.blue[900]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 Profile Image
            GestureDetector(
              onTap: isEditing ? pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (user['imagePath'] != null ? FileImage(File(user['imagePath']!)) : null),
                child: _image == null && user['imagePath'] == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildField("Name", nameController, enabled: isEditing),
                    _buildField("Email", emailController, enabled: isEditing),
                    _buildField("Phone", phoneController, enabled: isEditing),
                    _buildField("Father Name", fatherController, enabled: isEditing),
                    _buildField("Present Address", presentAddressController, enabled: isEditing),
                    _buildField("Permanent Address", permanentAddressController, enabled: isEditing),
                    _buildField("NID", nidController, enabled: isEditing),
                    _buildField("Location", locationController, enabled: isEditing),

                    // User Type (readonly)
                    _buildField("User Type", TextEditingController(text: user['userType']), enabled: false),

                    // Gender dropdown editable
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gender", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ["Male","Female","Other"].contains(gender) ? gender : null,
                                isExpanded: true,
                                onChanged: isEditing
                                    ? (value) {
                                        setState(() {
                                          gender = value!;
                                        });
                                      }
                                    : null,
                                items: const [
                                  DropdownMenuItem(value: "Male", child: Text("Male")),
                                  DropdownMenuItem(value: "Female", child: Text("Female")),
                                  DropdownMenuItem(value: "Other", child: Text("Other")),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(isEditing ? "Save Changes" : "Update Profile", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------------- POST JOB PAGE ----------------------
class PostJobPage extends StatefulWidget {
  final Map<String, String> employerData; // Employer info pass korte hobe

  const PostJobPage({super.key, required this.employerData});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();

  String jobType = "Full-time";
  String jobCategory = "Driver"; // default category

  // Temporary job list (future Job Feed e use korte parba)
  List<Map<String, String>> postedJobs = [];

  void _postJob() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill at least Job Title and Description")),
      );
      return;
    }

    Map<String, String> job = {
      "title": titleController.text.trim(),
      "category": jobCategory,
      "company": widget.employerData['name'] ?? "",
      "location": locationController.text.trim(),
      "salary": salaryController.text.trim(),
      "description": descriptionController.text.trim(),
      "requirements": requirementsController.text.trim(),
      "jobType": jobType,
    };

    setState(() {
      postedJobs.add(job);
      // Clear fields
      titleController.clear();
      locationController.clear();
      salaryController.clear();
      descriptionController.clear();
      requirementsController.clear();
      jobType = "Full-time";
      jobCategory = "Driver";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Job posted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Job"),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Job Category Dropdown
            DropdownButtonFormField<String>(
              value: jobCategory,
              decoration: InputDecoration(
                labelText: "Job Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: "Driver", child: Text("Driver")),
                DropdownMenuItem(value: "Maid / House Helper", child: Text("Maid / House Helper")),
                DropdownMenuItem(value: "Security Guard", child: Text("Security Guard")),
                DropdownMenuItem(value: "Delivery Person", child: Text("Delivery Person")),
                DropdownMenuItem(value: "Electrician", child: Text("Electrician")),
                DropdownMenuItem(value: "Plumber", child: Text("Plumber")),
                DropdownMenuItem(value: "Carpenter", child: Text("Carpenter")),
                DropdownMenuItem(value: "Painter", child: Text("Painter")),
                DropdownMenuItem(value: "Cook / Chef", child: Text("Cook / Chef")),
                DropdownMenuItem(value: "Cleaner", child: Text("Cleaner")),
                DropdownMenuItem(value: "Others", child: Text("Others")),

              ],
              onChanged: (value) => setState(() => jobCategory = value!),
            ),
            const SizedBox(height: 15),

            // Job Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Job Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Salary
            TextField(
              controller: salaryController,
              decoration: InputDecoration(
                labelText: "Salary",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Job Type
            DropdownButtonFormField<String>(
              value: jobType,
              decoration: InputDecoration(
                labelText: "Job Type",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: "Full-time", child: Text("Full-time")),
                DropdownMenuItem(value: "Part-time", child: Text("Part-time")),
              ],
              onChanged: (value) => setState(() => jobType = value!),
            ),
            const SizedBox(height: 15),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Requirements
            TextField(
              controller: requirementsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Requirements",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 25),

            // Post Job Button
            ElevatedButton(
              onPressed: _postJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Post Job",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

// ---------------------- JOB BOARD PAGE ----------------------

class JobBoardPage extends StatelessWidget {
  const JobBoardPage({super.key});

  // Sample job data
  final List<Map<String, String>> jobs = const [
    {
      "title": "Delivery Person Needed",
      "category": "Delivery Person",
      "company": "FastExpress Ltd",
      "location": "Dhaka",
      "salary": "15000 BDT",
      "jobType": "Full-time",
      "description": "Looking for experienced delivery person for fast delivery service.",
      "requirements": "Must have a driving license and smartphone.",
    },
    {
      "title": "House Maid Required",
      "category": "Maid / House Helper",
      "company": "Family of Mr. Rahman",
      "location": "Mirpur",
      "salary": "12000 BDT",
      "jobType": "Full-time",
      "description": "Looking for honest and experienced house maid.",
      "requirements": "Must be trustworthy and experienced in household chores.",
    },
    {
      "title": "Driver Wanted",
      "category": "Driver",
      "company": "ABC Transport",
      "location": "Gulshan",
      "salary": "18000 BDT",
      "jobType": "Full-time",
      "description": "Experienced driver required for company vehicle.",
      "requirements": "Valid driving license, 2+ years experience.",
    },
    {
      "title": "Cleaner for Office",
      "category": "Cleaner",
      "company": "XYZ Corp",
      "location": "Banani",
      "salary": "10000 BDT",
      "jobType": "Part-time",
      "description": "Office cleaner required for 4 hours/day.",
      "requirements": "Punctual and hardworking.",
    },
    {
      "title": "Security Guard Needed",
      "category": "Security Guard",
      "company": "SecureHome Ltd",
      "location": "Uttara",
      "salary": "14000 BDT",
      "jobType": "Full-time",
      "description": "Looking for trained security guard for residential area.",
      "requirements": "Must have security experience.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Board"),
        backgroundColor: Colors.blue[900],
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Card(
            color: Colors.lightBlue[100], // All cards sky blue
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'] ?? "",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("${job['category']} - ${job['location']}"),
                  const SizedBox(height: 6),
                  Text("Salary: ${job['salary']} | Type: ${job['jobType']}"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Applied for ${job['title']}")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 69, 202, 98),
                        ),
                        child: const Text("Apply"),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(job['title'] ?? ""),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Category: ${job['category']}"),
                                    Text("Location: ${job['location']}"),
                                    Text("Salary: ${job['salary']}"),
                                    Text("Job Type: ${job['jobType']}"),
                                    const SizedBox(height: 8),
                                    Text("Description: ${job['description']}"),
                                    const SizedBox(height: 8),
                                    Text("Requirements: ${job['requirements']}"),
                                    const SizedBox(height: 8),
                                    Text("Company: ${job['company']}"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Details"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// ---------------------- APPLIED JOBS PAGE ----------------------


class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({super.key});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  // Sample applied jobs data
  List<Map<String, dynamic>> appliedJobs = [
    {
      "title": "Delivery Man",
      "company": "FoodExpress",
      "status": "Pending"
    },
    {
      "title": "House Maid",
      "company": "City Homes",
      "status": "Approved"
    },
    {
      "title": "Plumber",
      "company": "WaterFix Ltd",
      "status": "Declined"
    },
  ];

  // CCR phone number (customer care)
  final String ccrNumber = "tel:+8801XXXXXXXXX";

  Future<void> _callCCR() async {
    if (await canLaunchUrl(Uri.parse(ccrNumber))) {
      await launchUrl(Uri.parse(ccrNumber));
    } else {
      throw "Could not launch $ccrNumber";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(
          "Applied Jobs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: appliedJobs.length,
          itemBuilder: (context, index) {
            final job = appliedJobs[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blue[100],
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job title
                    Text(
                      job["title"],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Company name
                    Text(
                      job["company"],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status + Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status
                        _buildStatus(job["status"]),
                        const SizedBox(width: 10),

                        // Cancel button (always visible)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              appliedJobs.removeAt(index);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),

                    // CCR Button only if Approved
                    if (job["status"] == "Approved") ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _callCCR,
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text("Contact via CCR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for status
  Widget _buildStatus(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case "Approved":
        color = Colors.green;
        icon = Icons.check_circle;
        text = "Approved";
        break;
      case "Declined":
        color = Colors.red;
        icon = Icons.cancel;
        text = "Declined";
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        text = "Pending";
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
// ---------------------- CUSTOMER CARE PAGE ----------------------

class CustomerCarePage extends StatelessWidget {
  const CustomerCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          "Customer Care",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header Icon
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.support_agent,
                    size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "We’re Here to Help!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Our customer care representatives are available\n24/7 to assist you with any job-related queries.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),

              const SizedBox(height: 30),

              // Contact Options
              _contactOption(
                context,
                icon: Icons.call,
                title: "Call Us",
                subtitle: "+880 1234 567 890",
                color: Colors.green,
                onTap: () {
                  // এখানে url_launcher দিয়ে ফোন call করা যাবে
                },
              ),
              const SizedBox(height: 15),
              _contactOption(
                context,
                icon: Icons.email,
                title: "Email Us",
                subtitle: "support@worknest.com",
                color: Colors.orange,
                onTap: () {},
              ),
              const SizedBox(height: 15),
              _contactOption(
                context,
                icon: Icons.chat,
                title: "Live Chat",
                subtitle: "Connect instantly with CCR",
                color: Colors.blue,
                onTap: () {},
              ),

              const SizedBox(height: 40),

              // Extra Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Our CCR team can connect you with employers and job seekers directly via phone calls for smooth communication.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ---------------------- EMPLOYER JOB APPLICATIONS PAGE ----------------------

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({super.key});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  // Sample job applications list
  List<Map<String, dynamic>> jobApplications = [
    {
      'jobTitle': 'Delivery Man',
      'applicantName': 'Nasif',
      'status': 'Pending',
      'phone': '+880123456789'
    },
    {
      'jobTitle': 'House Maid',
      'applicantName': 'Rimpy',
      'status': 'Pending',
      'phone': '+880987654321'
    },
    {
      'jobTitle': 'Driver',
      'applicantName': 'Sifat',
      'status': 'Pending',
      'phone': '+880987654321'
    },
    {
      'jobTitle': 'Cleaner',
      'applicantName': 'Bidhan',
      'status': 'Pending',
      'phone': '+880987654321'
    },
    {
      'jobTitle': 'Security Guard',
      'applicantName': 'Alif',
      'status': 'Pending',
      'phone': '+880987654321'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text("Job Applications"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: jobApplications.length,
          itemBuilder: (context, index) {
            final application = jobApplications[index];
            Color statusColor;
            switch (application['status']) {
              case 'Approved':
                statusColor = Colors.green;
                break;
              case 'Cancelled':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application['jobTitle'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Applicant: ${application['applicantName']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          application['status'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontSize: 16),
                        ),
                        Row(
                          children: [
                            if (application['status'] == 'Pending') ...[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    application['status'] = 'Approved';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "${application['applicantName']} approved! Customer Care can now call.")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text("Approve"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    application['status'] = 'Cancelled';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Cancel"),
                              ),
                            ] else if (application['status'] == 'Approved') ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Launch customer care call functionality
                                  final ccrNumber = application['phone'];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Call Customer Care to connect with ${application['applicantName']}")),
                                  );
                                },
                                icon: const Icon(Icons.call),
                                label: const Text("CCR Call"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900]),
                              )
                            ]
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


