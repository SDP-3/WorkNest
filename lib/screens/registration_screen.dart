import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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
  final TextEditingController presentAddressController = TextEditingController();
  final TextEditingController permanentAddressController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? userType;
  String? gender;

  // --- Image picker function ---
  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  // --- Location picker function ---
  Future<void> getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services')));
      setState(() { _isLoading = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        setState(() { _isLoading = false; });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
      _isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location Captured!')));
    });
  }

  // --- Input Decoration ---
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white, width: 0.0)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red, width: 1.0)
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red, width: 2.0)
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
        borderSide: BorderSide(color: Colors.white, width: 0.0)
      ),
      prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
    );
  }

  // --- Register function (No Firebase) ---
  void _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields correctly"))
      );
      return;
    }

    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulating backend call
    await Future.delayed(const Duration(seconds: 2));

    Map<String, dynamic> userData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'fatherName': fatherController.text.trim(),
      'presentAddress': presentAddressController.text.trim(),
      'permanentAddress': permanentAddressController.text.trim(),
      'nid': nidController.text.trim(),
      'userType': userType,
      'gender': gender,
      'location': _location,
      'imageUrl': _image?.path,
    };
    
    print("--- Registration Data (Frontend Validated) ---");
    print(userData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration Successful! (Backend Pending)"))
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context); // Go back to Login screen
    }
  }

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
                    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
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
                    bool mobileValid = RegExp(r"^01[3-9]\d{8}$").hasMatch(value);
                    if (!mobileValid) {
                      return 'Please enter a valid 11-digit Bangladeshi number (01...)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: fatherController,
                  decoration: _inputDecoration("Father Name", Icons.person_outline),
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: presentAddressController,
                  decoration: _inputDecoration("Present Address", Icons.location_on_outlined),
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: permanentAddressController,
                  decoration: _inputDecoration("Permanent Address", Icons.location_city),
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: nidController,
                  decoration: _inputDecoration("NID / Birth Certificate", Icons.badge),
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
                  decoration: _inputDecoration("Confirm Password", Icons.lock_outline),
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
                  value: userType,
                  items: const [
                    DropdownMenuItem(value: "jobSeeker", child: Text("Job Seeker")),
                    DropdownMenuItem(value: "employer", child: Text("Employer")),
                  ],
                  onChanged: (value) { setState(() { userType = value; }); },
                  decoration: _inputDecorationDropdown("Select User Type"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value == null ? 'Please select a user type' : null,
                ),
                const SizedBox(height: 15),
                
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) { setState(() { gender = value; }); },
                  decoration: _inputDecorationDropdown("Select Gender"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 15),

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
                    child: Text("Location Captured!", style: TextStyle(color: Colors.blue[900])),
                  ),

                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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