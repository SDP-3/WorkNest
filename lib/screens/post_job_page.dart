import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

// ---------------------- POST JOB PAGE ----------------------
class PostJobPage extends StatefulWidget {
  // Employer data passed to know who is posting the job
  final Map<String, String> employerData;

  const PostJobPage({super.key, required this.employerData});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  // Controllers for text fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();

  // State variables for dropdowns
  String jobType = "Full-time"; // Default selection
  String jobCategory = "Driver"; // Default selection

  // List of job categories for the dropdown
  final List<String> _jobCategories = const [
    "Driver",
    "Maid / House Helper",
    "Security Guard",
    "Delivery Person",
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
    "Cook / Chef",
    "Cleaner",
    "Others",
  ];

  // List of job types for the dropdown
  final List<String> _jobTypes = const [
    "Full-time",
    "Part-time",
  ];

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    titleController.dispose();
    locationController.dispose();
    salaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    super.dispose();
  }

  // Function to handle posting the job
  void _postJob() {
    // Basic validation
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill at least Job Title and Description"),
            backgroundColor: Colors.redAccent), // Error color
      );
      return;
    }

    // Prepare job data (replace with your data model if you have one)
    Map<String, String> jobData = {
      "title": titleController.text.trim(),
      "category": jobCategory,
      "company": widget.employerData['name'] ?? "N/A", // Get company name from employerData
      "employerEmail": widget.employerData['email'] ?? "N/A", // Add employer email
      "location": locationController.text.trim(),
      "salary": salaryController.text.trim(),
      "description": descriptionController.text.trim(),
      "requirements": requirementsController.text.trim(),
      "jobType": jobType,
      "postedDate": DateTime.now().toIso8601String(), // Add a timestamp
    };

    // TODO: Add backend API call here to save the jobData to your database

    print("Job Data to Post: $jobData"); // For debugging

    // Clear the form fields after successful posting attempt
    setState(() {
      titleController.clear();
      locationController.clear();
      salaryController.clear();
      descriptionController.clear();
      requirementsController.clear();
      jobType = _jobTypes.first; // Reset to default
      jobCategory = _jobCategories.first; // Reset to default
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Job posted successfully (Backend Pending)"),
          backgroundColor: Colors.green), // Success color
    );

    // Optionally navigate back after posting
    Navigator.pop(context);
  }

  // Helper for input decoration
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]), // Consistent font
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue[800]) : null, // Optional icon
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjusted padding
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post a New Job", style: GoogleFonts.poppins()), // Consistent font
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch horizontally
          children: [
            // Job Category Dropdown
            DropdownButtonFormField<String>(
              value: jobCategory,
              decoration: _inputDecoration("Job Category", icon: Icons.category_rounded),
              items: _jobCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: GoogleFonts.poppins()), // Consistent font
                );
              }).toList(),
              onChanged: (value) => setState(() => jobCategory = value!),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16), // Dropdown text style
            ),
            const SizedBox(height: 15),

            // Job Title
            TextField(
              controller: titleController,
              decoration: _inputDecoration("Job Title", icon: Icons.title_rounded),
              style: GoogleFonts.poppins(fontSize: 16), // Consistent font size
            ),
            const SizedBox(height: 15),

            // Location
            TextField(
              controller: locationController,
              decoration: _inputDecoration("Location", icon: Icons.location_on_rounded),
               style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Salary
            TextField(
              controller: salaryController,
              decoration: _inputDecoration("Salary (e.g., 15000 BDT/month)", icon: Icons.attach_money_rounded),
              keyboardType: TextInputType.text, // Allow text like "Negotiable"
               style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Job Type Dropdown
            DropdownButtonFormField<String>(
              value: jobType,
              decoration: _inputDecoration("Job Type", icon: Icons.timer_rounded),
              items: _jobTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: GoogleFonts.poppins()), // Consistent font
                );
              }).toList(),
              onChanged: (value) => setState(() => jobType = value!),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 4, // Increased lines
              decoration: _inputDecoration("Job Description", icon: Icons.description_rounded)
                  .copyWith(alignLabelWithHint: true), // Align label to top
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Requirements
            TextField(
              controller: requirementsController,
              maxLines: 4, // Increased lines
              decoration: _inputDecoration("Requirements", icon: Icons.checklist_rounded)
                 .copyWith(alignLabelWithHint: true), // Align label to top
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 30), // Increased spacing

            // Post Job Button
            ElevatedButton(
              onPressed: _postJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900], // Dark blue button
                foregroundColor: Colors.white, // White text
                minimumSize: const Size(double.infinity, 50), // Full width
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14), // Vertical padding
                elevation: 3, // Add shadow
              ),
              child: Text(
                "Post Job",
                style: GoogleFonts.poppins( // Consistent font
                    fontWeight: FontWeight.bold, fontSize: 17), // Slightly larger font
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100], // Light grey background
    );
  }
}