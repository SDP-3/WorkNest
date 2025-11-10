import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

// <<<--- ১. Firebase প্যাকেজগুলো ইম্পোর্ট করুন ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// TODO: ছবি আপলোডের জন্য 'firebase_storage' প্যাকেজ অ্যাড করতে হবে

// ---------------------- REGISTRATION SCREEN ----------------------
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  File? _image;
  String _location = "";
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController presentAddressController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? userType;
  String? gender;

  // --- ইমেজ পিকার ফাংশন ---
  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  // --- লোকেশন পিকার ফাংশন ---
  Future<void> getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enable location services')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
      _isLoading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location Captured!')));
    });
  }

  // --- ইনপুট ডেকোরেশন ---
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white, width: 0.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  InputDecoration _inputDecorationDropdown(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white, width: 0.0),
      ),
      prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
    );
  }

  // <<<--- ২. _registerUser ফাংশন (Firebase সহ) ---
  void _registerUser() async {
    // ধাপ ক: ফর্ম ভ্যালিড কি না চেক করুন
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields correctly"),
        ),
      );
      return;
    }

    // ধাপ খ: পাসওয়ার্ড ম্যাচিং চেক
    String password = passwordController.text.trim();
    if (password != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    // ধাপ গ: লোডিং শুরু করুন
    setState(() {
      _isLoading = true;
    });

    try {
      // ধাপ ঘ: FirebaseAuth-এ ইউজার তৈরি করুন
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: password,
          );

      String uid = userCredential.user!.uid;
      String? imageUrl;

      // TODO: এখানে ছবি Firebase Storage-এ আপলোড করতে হবে
      // এবং imageUrl = await storageRef.getDownloadURL(); দিয়ে URL নিতে হবে।
      // আপাতত শুধু লোকাল পাথ সেভ করা হচ্ছে, যা ঠিক নয়।
      if (_image != null) {
        imageUrl = _image!.path; // (Temporary placeholder)
      }

      // ধাপ ঙ: Cloud Firestore-এ ইউজারের সব তথ্য সেভ করুন
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'fatherName': fatherController.text.trim(),
        'presentAddress': presentAddressController.text.trim(),
        'permanentAddress': permanentAddressController.text.trim(),
        'nid': nidController.text.trim(),
        'userType': userType, // 'jobSeeker' or 'employer'
        'gender': gender, // 'Male', 'Female', 'Other'
        'location': _location, // Lat, Long string
        'imageUrl': imageUrl, // ছবির URL
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ধাপ চ: সফল হলে লগইন পেজে ফেরত যান
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful! Please log in."),
        ),
      );
      Navigator.pop(context); // রেজিস্ট্রেশন পেজ বন্ধ করে লগইন পেজে ফেরত যাবে
    } on FirebaseAuthException catch (e) {
      // যদি Firebase কোনো एरর দেয় (যেমন: ইমেইল আগেই ব্যবহৃত)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: ${e.message}")),
      );
    } catch (e) {
      // অন্য কোনো एरর হলে
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An unknown error occurred: $e")));
    }

    // ধাপ ছ: লোডিং শেষ করুন
    if (mounted) {
      // উইজেটটি তখনো স্ক্রিনে আছে কি না তা চেক করে
      setState(() {
        _isLoading = false;
      });
    }
  }
  // <<<--- ফাংশন আপডেট করা শেষ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- ইমেজ পিকার ---
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.blue,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // --- TextFormField-গুলো ---
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Name", Icons.person),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Email", Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value);
                    if (!emailValid) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: phoneController,
                  decoration: _inputDecoration("Phone", Icons.phone),
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    bool mobileValid = RegExp(
                      r"^01[3-9]\d{8}$",
                    ).hasMatch(value);
                    if (!mobileValid) {
                      return 'Please enter a valid 11-digit Bangladeshi number (01...)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: fatherController,
                  decoration: _inputDecoration(
                    "Father Name",
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: presentAddressController,
                  decoration: _inputDecoration(
                    "Present Address",
                    Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: permanentAddressController,
                  decoration: _inputDecoration(
                    "Permanent Address",
                    Icons.location_city,
                  ),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: nidController,
                  decoration: _inputDecoration(
                    "NID / Birth Certificate",
                    Icons.badge,
                  ),
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your NID/Birth Certificate number';
                    }
                    bool isNumeric = RegExp(r"^[0-9]+$").hasMatch(value);
                    if (!isNumeric) {
                      return 'Only numbers are allowed';
                    }
                    if (value.length < 10) {
                      return 'Must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.lock),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    "Confirm Password",
                    Icons.lock_outline,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  initialValue: userType,
                  items: const [
                    DropdownMenuItem(
                      value: "jobSeeker",
                      child: Text("Job Seeker"),
                    ),
                    DropdownMenuItem(
                      value: "employer",
                      child: Text("Employer"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      userType = value;
                    });
                  },
                  decoration: _inputDecorationDropdown("Select User Type"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value == null ? 'Please select a user type' : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  initialValue: gender,
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  decoration: _inputDecorationDropdown("Select Gender"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 15),

                // --- লোকেশন বাটন ---
                ElevatedButton(
                  onPressed: getUserLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                    shadowColor: Colors.blueAccent,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                if (_location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Location Captured!",
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),

                const SizedBox(height: 20),

                // --- রেজিস্টার বাটন ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
