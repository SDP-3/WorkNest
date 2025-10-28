import 'dart:io'; // 🔹 Import যোগ করা হয়েছে
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 🔹 Import যোগ করা হয়েছে
import 'package:image_picker/image_picker.dart'; // 🔹 Import যোগ করা হয়েছে
import 'package:geolocator/geolocator.dart'; // 🔹 Import যোগ করা হয়েছে

// --------------------------- EMPLOYER PROFILE PAGE ---------------------------

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
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _location = "";

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
    _location = user['location'] ?? "";
    selectedGender = user['gender'];
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

  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
      locationController.text = _location;
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

      if (selectedGender != null && ["Male", "Female", "Other"].contains(selectedGender)) {
        user['gender'] = selectedGender!;
      }

      if (_image != null) user['imagePath'] = _image!.path;
      isEditing = false;
    });

    widget.onUpdate(user); // 🔹 Ekhane backend e update call hobe

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
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
              onTap: isEditing ? pickImage : null,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (user['imagePath'] != null
                        ? FileImage(File(user['imagePath']!))
                        : null),
                child: _image == null && user['imagePath'] == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
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
                    _buildField("NID / Birth Certificate", nidController, enabled: isEditing),

                    // Location field like registration screen
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900])),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: locationController,
                                  enabled: false,
                                  decoration: _inputDecoration("Location"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: _getUserLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  child: const Icon(Icons.location_on,
                                      color: Colors.blue, size: 28),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // User Type (readonly)
                    _buildField("User Type",
                        TextEditingController(text: user['userType']), enabled: false),

                    // Gender dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gender",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900])),
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
                                        ["Male", "Female", "Other"].contains(selectedGender)
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
              child: Text(isEditing ? "Save Changes" : "Update Profile",
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}