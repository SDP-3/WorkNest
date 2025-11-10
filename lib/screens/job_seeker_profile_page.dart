import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

// --------------------------- JOB SEEKER PROFILE PAGE (FIXED) ---------------------------

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

  String? gender; // Nullable করা হলো যাতে ক্র্যাশ না করে

  @override
  void initState() {
    super.initState();
    user = Map.from(widget.userData);

    nameController = TextEditingController(text: user['name'] ?? "");
    emailController = TextEditingController(text: user['email'] ?? "");
    phoneController = TextEditingController(text: user['phone'] ?? "");
    
    // FIX: 'father' এর বদলে 'fatherName' ব্যবহার করা হলো
    fatherController = TextEditingController(text: user['fatherName'] ?? user['father'] ?? ""); 
    
    presentAddressController = TextEditingController(text: user['presentAddress'] ?? "");
    permanentAddressController = TextEditingController(text: user['permanentAddress'] ?? "");
    nidController = TextEditingController(text: user['nid'] ?? "");
    locationController = TextEditingController(text: user['location'] ?? "");
    
    // জেন্ডার ভ্যালু চেক করে সেট করা হচ্ছে
    String? g = user['gender'];
    if (g != null && ["Male", "Female", "Other"].contains(g)) {
      gender = g;
    } else {
      gender = null;
    }
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

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      locationController.text = "Lat: ${position.latitude}, Lon: ${position.longitude}";
    });
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
      // user['email'] = emailController.text.trim(); // ইমেইল সাধারণত আপডেট করা হয় না
      user['phone'] = phoneController.text.trim();
      user['fatherName'] = fatherController.text.trim(); // FIX: 'fatherName'
      user['presentAddress'] = presentAddressController.text.trim();
      user['permanentAddress'] = permanentAddressController.text.trim();
      user['nid'] = nidController.text.trim();
      user['location'] = locationController.text.trim();

      if (gender != null) user['gender'] = gender!;
      if (_image != null) user['imagePath'] = _image!.path;

      isEditing = false;
    });

    widget.onUpdate(user); // ব্যাকএন্ড আপডেট কল

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            GestureDetector(
              onTap: isEditing ? pickImage : null,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (user['imagePath'] != null && user['imagePath']!.isNotEmpty 
                        ? FileImage(File(user['imagePath']!)) 
                        : null),
                child: _image == null && (user['imagePath'] == null || user['imagePath']!.isEmpty)
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
                    _buildField("Email", emailController, enabled: false), // ইমেইল রিড-অনলি
                    _buildField("Phone", phoneController, enabled: isEditing),
                    _buildField("Father Name", fatherController, enabled: isEditing),
                    _buildField("Present Address", presentAddressController, enabled: isEditing),
                    _buildField("Permanent Address", permanentAddressController, enabled: isEditing),
                    _buildField("NID / Birth Certificate", nidController, enabled: isEditing),

                    // Location field with button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: locationController,
                                  enabled: false, // লোকেশন শুধু বাটন দিয়েই নেওয়া যাবে
                                  decoration: _inputDecoration("Location"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: getCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  child: const Icon(Icons.location_on, color: Colors.blue, size: 28),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // User Type (readonly)
                    _buildField("User Type", TextEditingController(text: user['userType'] ?? "Job Seeker"), enabled: false),

                    // Gender dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gender",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[900])),
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
                                value: gender,
                                hint: const Text("Select Gender"),
                                isExpanded: true,
                                onChanged: isEditing
                                    ? (value) {
                                        setState(() {
                                          gender = value;
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