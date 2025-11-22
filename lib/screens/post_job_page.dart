import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_posted_jobs_page.dart'; // আপনার তৈরি করা নতুন পেজটি ইম্পোর্ট করা হলো

class PostJobPage extends StatefulWidget {
  final Map<String, String> employerData;

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
  String jobCategory = "Driver";
  bool _isLoading = false; // লোডিং ইন্ডিকেটর দেখানোর জন্য

  final List<String> _jobCategories = const [
    "Driver", "Maid / House Helper", "Security Guard", "Delivery Person",
    "Electrician", "Plumber", "Carpenter", "Painter", "Cook / Chef",
    "Cleaner", "Others",
  ];

  final List<String> _jobTypes = const [
    "Full-time", "Part-time",
  ];

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    salaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    super.dispose();
  }

  // জব পোস্ট করার ফাংশন (Firebase সহ)
  Future<void> _postJob() async {
    // ১. ইনপুট ভ্যালিডেশন
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        salaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required fields"),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true; // লোডিং শুরু
    });

    try {
      // ২. বর্তমান ইউজারের UID নেওয়া
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // ৩. Firestore-এ ডেটা পাঠানো
      await FirebaseFirestore.instance.collection('jobs').add({
        "job_title": titleController.text.trim(),
        "category": jobCategory,
        "company_name": widget.employerData['name'] ?? "N/A",
        "employer_email": widget.employerData['email'] ?? user.email ?? "N/A",
        "location": locationController.text.trim(),
        "salary": salaryController.text.trim(),
        "description": descriptionController.text.trim(),
        "requirements": requirementsController.text.trim(),
        "job_type": jobType,
        "posted_at": FieldValue.serverTimestamp(), // সার্ভারের সময়
        "posted_by_uid": user.uid, // ইউজারের UID (My Jobs ফিল্টার করার জন্য জরুরি)
      });

      // ৪. সফল হলে মেসেজ দেখানো ও ফর্ম ক্লিয়ার করা
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Job Posted Successfully!"),
            backgroundColor: Colors.green),
      );

      setState(() {
        titleController.clear();
        locationController.clear();
        salaryController.clear();
        descriptionController.clear();
        requirementsController.clear();
        jobType = _jobTypes.first;
        jobCategory = _jobCategories.first;
        _isLoading = false; // লোডিং শেষ
      });

      // চাইলে এখানে অটোমেটিক My Jobs পেজে নিয়ে যাওয়া যায়:
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPostedJobsPage()));

    } catch (e) {
      // ৫. কোনো এরর হলে দেখানো
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error posting job: ${e.toString()}"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue[800]) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post a New Job", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: jobCategory,
              decoration: _inputDecoration("Job Category", icon: Icons.category_rounded),
              items: _jobCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) => setState(() => jobCategory = value!),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: _inputDecoration("Job Title", icon: Icons.title_rounded),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: locationController,
              decoration: _inputDecoration("Location", icon: Icons.location_on_rounded),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: salaryController,
              decoration: _inputDecoration("Salary (e.g., 15000 BDT/month)", icon: Icons.attach_money_rounded),
              keyboardType: TextInputType.text,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: jobType,
              decoration: _inputDecoration("Job Type", icon: Icons.timer_rounded),
              items: _jobTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) => setState(() => jobType = value!),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration("Job Description", icon: Icons.description_rounded)
                  .copyWith(alignLabelWithHint: true),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: requirementsController,
              maxLines: 4,
              decoration: _inputDecoration("Requirements", icon: Icons.checklist_rounded)
                  .copyWith(alignLabelWithHint: true),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // ---------- POST JOB BUTTON (With Loading State) ----------
            ElevatedButton(
              onPressed: _isLoading ? null : _postJob, // লোডিং অবস্থায় বাটন ডিজেবল থাকবে
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      "Post Job",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
            ),

            // ---------- MY POSTED JOBS BUTTON ----------
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () {
                // এখানে সরাসরি নতুন পেজে নেভিগেট করা হচ্ছে
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPostedJobsPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[900],
                side: BorderSide(color: Colors.blue[900]!, width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "My Posted Jobs",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}