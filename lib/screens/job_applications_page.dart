import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ❗️ Firebase ইম্পোর্ট
import 'package:firebase_auth/firebase_auth.dart'; // ❗️ Auth ইম্পোর্ট

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({super.key});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  // ১. Firebase থেকে ডেটা আনার জন্য Stream
  Stream<QuerySnapshot>? _applicationsStream;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      // শুধু এই এমপ্লয়ারের (logged in user) অ্যাপ্লিকেশনগুলো আনা হচ্ছে
      _applicationsStream = FirebaseFirestore.instance
          .collection('applications')
          .where('employer_uid', isEqualTo: _user!.uid) // <-- মূল ফিল্টারিং
          .orderBy('applied_at', descending: true)
          .snapshots();
    }
  }

  // --- ২. স্ট্যাটাস আপডেট করার ফাংশন (Firebase-এ) ---
  Future<void> _updateStatus(String applicationId, String newStatus, String applicantName) async {
    // context চেক করা (গুরুত্বপূর্ণ)
    if (!mounted) return; 

    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': newStatus}); // <-- Firebase-এ স্ট্যাটাস আপডেট

      // ইউজারের আগের SnackBar লজিক
      if (newStatus == 'approved') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$applicantName approved! CCR will contact."),
            backgroundColor: Colors.green,
          ),
        );
      } else if (newStatus == 'declined') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$applicantName's application declined."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // <-- আপনার ছবির ডিজাইনের মতো হালকা নীল
      appBar: AppBar(
        title: Text("Job Applications", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // --- ৩. StreamBuilder দিয়ে Firebase ডেটা লোড ---
      body: StreamBuilder<QuerySnapshot>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          // যদি ডেটা লোড হয়
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // যদি কোনো এরর হয়
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()));
          }
          // যদি কোনো অ্যাপ্লিকেশন না থাকে
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No applications received yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
            );
          }

          // যদি ডেটা সফলভাবে আসে
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                // Firebase ডকুমেন্ট থেকে ডেটা ম্যাপ করা
                final doc = snapshot.data!.docs[index];
                final application = doc.data() as Map<String, dynamic>;
                final applicationId = doc.id; // <-- ডকুমেন্ট ID (আপডেট করার জন্য)

                Color statusColor;
                IconData statusIcon;
                // ৪. স্ট্যাটাসটি ছোট হাতের অক্ষরে নেওয়া
                String statusText = (application['status'] ?? "pending").toLowerCase();

                switch (statusText) {
                  case 'approved': 
                    statusColor = Colors.green[700]!;
                    statusIcon = Icons.check_circle_outline;
                    statusText = "Approved"; // Capitalize for display
                    break;
                  case 'declined': 
                    statusColor = Colors.red[700]!;
                    statusIcon = Icons.highlight_off;
                    statusText = "Declined"; // Capitalize for display
                    break;
                  default: // Pending
                    statusColor = Colors.orange[700]!;
                    statusIcon = Icons.hourglass_empty_outlined;
                    statusText = "Pending";
                }

                // আপনার ডিজাইন করা কার্ড
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ৫. Job Title
                        Text(
                          application['job_title'] ?? "N/A", 
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Applicant Name and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ৬. Applicant Name
                            Expanded(
                              child: Text(
                                "Applicant: ${application['applicant_name'] ?? 'N/A'}", 
                                style: GoogleFonts.poppins(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Status Display
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: statusColor, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // --- ৭. Action Buttons (Firebase সহ) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Details Button
                            OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    // --- ⚠️ ইমেইল ও ফোন নম্বর সরানো হয়েছে ---
                                    final father = application['father_name'] ?? 'N/A';
                                    final presentAddress = application['present_address'] ?? 'N/A';
                                    final permanentAddress = application['permanent_address'] ?? 'N/A';
                                    final nid = application['nid_number'] ?? 'N/A';
                                    final gender = application['gender'] ?? 'N/A';
                                    final location = application['applicant_location'] ?? 'N/A';
                                    final bio = application['bio'] ?? 'No bio provided.';

                                    return AlertDialog(
                                      title: Text(application['applicant_name'] ?? 'Applicant Details', style: GoogleFonts.poppins()),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            // --- ⚠️ ইমেইল ও ফোন নম্বর এখান থেকেও সরানো হয়েছে ---
                                            _buildDetailRow("Father:", father),
                                            _buildDetailRow("Present Addr:", presentAddress),
                                            _buildDetailRow("Permanent Addr:", permanentAddress),
                                            _buildDetailRow("NID:", nid),
                                            _buildDetailRow("Gender:", gender),
                                            _buildDetailRow("Location:", location),
                                            const SizedBox(height: 8),
                                            Text("Bio:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                            Text(bio, style: GoogleFonts.poppins()),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("Close", style: GoogleFonts.poppins()),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Text("Details", style: GoogleFonts.poppins()),
                            ),
                            const SizedBox(width: 8),

                            // Conditional Buttons
                            if (statusText == 'Pending') ...[
                              // Approve Button
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(
                                    applicationId,
                                    'approved', // <-- ছোট হাতের
                                    application['applicant_name'] ?? 'Applicant',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text("Approve", style: GoogleFonts.poppins()),
                              ),
                              const SizedBox(width: 8),
                              // Decline Button
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(
                                    applicationId,
                                    'declined', // <-- ছোট হাতের
                                    application['applicant_name'] ?? 'Applicant',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text("Decline", style: GoogleFonts.poppins()),
                              ),
                            ] else if (statusText == 'Approved') ...[
                              // CCR Call Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Notifying CCR to connect with ${application['applicant_name'] ?? 'applicant'}"),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.headset_mic_rounded, size: 18),
                                label: Text("Request CCR Call", style: GoogleFonts.poppins(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                ),
                              ),
                            ]
                          ],
                        )
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

  // Details ডায়ালগের জন্য হেল্পার উইজেট
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
} 