import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:cloud_firestore/cloud_firestore.dart'; // ❗️ Firebase ইম্পোর্ট
import 'package:firebase_auth/firebase_auth.dart'; // ❗️ Auth ইম্পোর্ট

class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({super.key});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  // ১. Firebase থেকে ডেটা আনার জন্য Stream
  Stream<QuerySnapshot>? _applicationsStream;
  User? _user;

  // Customer Care Representative (CCR) ফোন নম্বর
  final String ccrNumber = "tel:+8801XXXXXXXXX";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      // শুধু এই ইউজারের (logged in user) অ্যাপ্লিকেশনগুলো আনা হচ্ছে
      _applicationsStream = FirebaseFirestore.instance
          .collection('applications')
          .where('applicant_uid', isEqualTo: _user!.uid) // <-- মূল ফিল্টারিং
          .orderBy('applied_at', descending: true)
          .snapshots();
    }
  }

  // Function to launch the phone dialer
  Future<void> _callCCR() async {
    final Uri ccrUri = Uri.parse(ccrNumber);
    if (await canLaunchUrl(ccrUri)) {
      await launchUrl(ccrUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $ccrNumber")),
        );
      }
    }
  }

  // --- ২. অ্যাপ্লিকেশন Cancel করার ফাংশন (Firebase সহ) ---
  Future<void> _cancelApplication(String documentId) async {
    // ইউজারকে কনফার্ম করতে বলা
    final bool? didConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Application?", style: GoogleFonts.poppins()),
        content: Text("Are you sure you want to cancel this job application?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // ইউজার "Yes" বললে ডকুমেন্ট ডিলিট করা হবে
    if (didConfirm == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(documentId)
            .delete(); // <-- Firebase থেকে ডিলিট

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application cancelled successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel application: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // <-- আপনার ছবির ডিজাইনের মতো হালকা নীল
      appBar: AppBar(
        title: Text(
          "Applied Jobs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      // --- ৩. StreamBuilder দিয়ে Firebase ডেটা লোড ---
      body: StreamBuilder<QuerySnapshot>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          // যদি ইউজার লগইন না থাকে
          if (_user == null) {
            return Center(child: Text("Please log in", style: GoogleFonts.poppins()));
          }
          // যদি ডেটা লোড হয়
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // যদি কোনো এরর হয়
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()));
          }
          // যদি কোনো অ্যাপ্লিকেশন না থাকে (আপনার আগের সমস্যার সমাধান)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You have not applied for any jobs yet.",
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey[800]), // Muted text
                textAlign: TextAlign.center,
              ),
            );
          }

          // যদি ডেটা সফলভাবে আসে
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                // Firebase ডকুমেন্ট থেকে ডেটা ম্যাপ করা
                final doc = snapshot.data!.docs[index];
                final job = doc.data() as Map<String, dynamic>;
                final documentId = doc.id; // <-- ডকুমেন্ট ID (ডিলিট করার জন্য)

                // ৪. ফিল্ডের নাম ফিক্স করা (Firebase অনুযায়ী)
                final String jobTitle = job["job_title"] ?? "N/A";
                final String companyName = job["company_name"] ?? "N/A";
                final String status = job["status"] ?? "pending"; // 'pending' (lowercase)

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white, // <-- কার্ডের রঙ সাদা
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job title
                        Text(
                          jobTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Company name
                        Text(
                          companyName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Row containing Status and Cancel button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status Display
                            _buildStatus(status), // <-- 'status' পাস করা
                            const SizedBox(width: 10),

                            // --- ৫. Cancel Button (আপডেটেড) ---
                            // যদি স্ট্যাটাস 'pending' হয়, তবেই Cancel বাটন দেখাও
                            if (status == 'pending')
                              ElevatedButton(
                                onPressed: () => _cancelApplication(documentId), // <-- ID পাস করা
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text("Cancel", style: GoogleFonts.poppins()), // ফন্ট যোগ করা
                              ),
                          ],
                        ),

                        // "Contact via CCR" বাটন (যদি 'approved' হয়)
                        if (status == "approved") ...[ // <-- 'approved' (lowercase)
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _callCCR,
                            icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                            label: Text(
                              "Contact via CCR",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
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
          );
        },
      ),
    );
  }

  // Helper widget to display status (এটি ঠিক আছে)
  Widget _buildStatus(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case "approved":
        statusColor = Colors.green[700]!;
        statusIcon = Icons.check_circle_outline;
        statusText = "Approved";
        break;
      case "declined":
      case "cancelled":
        statusColor = Colors.red[700]!;
        statusIcon = Icons.highlight_off;
        statusText = "Declined"; // "Cancelled" এর বদলে "Declined" দেখানো ভালো
        break;
      default: // Pending
        statusColor = Colors.orange[700]!;
        statusIcon = Icons.hourglass_empty_outlined;
        statusText = "Pending";
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 6),
        Text(
          statusText,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
