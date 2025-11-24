// screens/job_applications_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({super.key});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  Stream<QuerySnapshot>? _applicationsStream;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _applicationsStream = FirebaseFirestore.instance
          .collection('applications')
          .where('employer_uid', isEqualTo: _user!.uid)
          .orderBy('applied_at', descending: true)
          .snapshots();
    }
  }

  // --- ১. অ্যাপ্লিকেশন রিমুভ/ডিলিট করার ফাংশন (নতুন) ---
  Future<void> _removeApplication(String docId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Remove Application?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to remove this application list?",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Yes, Remove",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Application removed successfully.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  // --- ২. কল করার ফাংশন ---
  Future<void> _callApplicant(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone number not available"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final Uri callUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not dial $phoneNumber")));
      }
    }
  }

  // --- ৩. স্ট্যাটাস আপডেট (Accept/Decline) ---
  Future<void> _updateStatus(
    String applicationId,
    String newStatus,
    String applicantName,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'approved'
                  ? "Application Accepted!"
                  : "Application Declined.",
            ),
            backgroundColor: newStatus == 'approved'
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- ৪. রিপোর্ট করার ফাংশন ---
  Future<void> _reportApplicant(
    String applicantUid,
    String applicantName,
  ) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Report Applicant?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Why are you reporting $applicantName?",
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Reason...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance.collection('reports').add({
          'reported_uid': applicantUid,
          'reporter_uid': _user!.uid,
          'reason': reasonController.text.isNotEmpty
              ? reasonController.text
              : "Employer reported applicant",
          'created_at': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report sent to Admin."),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        // Error handling
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text(
          "Job Applications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No applications received yet.",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final app = doc.data() as Map<String, dynamic>;
              final appId = doc.id;

              String status = (app['status'] ?? 'pending').toLowerCase();
              String applicantName = app['applicant_name'] ?? 'N/A';
              String applicantPhone = app['applicant_phone'] ?? '';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              app['job_title'] ?? "Job Title",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _reportApplicant(
                              app['applicant_uid'],
                              applicantName,
                            ),
                            icon: const Icon(
                              Icons.flag_outlined,
                              color: Colors.red,
                            ),
                            tooltip: "Report Applicant",
                          ),
                        ],
                      ),

                      Text(
                        "Applicant: $applicantName",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? Colors.green[100]
                              : (status == 'declined'
                                    ? Colors.red[100]
                                    : Colors.orange[100]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == 'approved'
                                ? Colors.green[800]
                                : (status == 'declined'
                                      ? Colors.red[800]
                                      : Colors.orange[800]),
                          ),
                        ),
                      ),
                      const Divider(height: 20),

                      // Action Buttons Wrap (যাতে বাটন বেশি হলে নিচে চলে যায়)
                      Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        alignment: WrapAlignment.end,
                        children: [
                          // 1. Details Button
                          OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    "Applicant Details",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        _buildDetailRow("Name:", applicantName),
                                        _buildDetailRow(
                                          "Phone:",
                                          applicantPhone,
                                        ),
                                        _buildDetailRow(
                                          "Email:",
                                          app['applicant_email'],
                                        ),
                                        const Divider(),
                                        _buildDetailRow(
                                          "Father:",
                                          app['father_name'],
                                        ),
                                        _buildDetailRow(
                                          "Present Addr:",
                                          app['present_address'],
                                        ),
                                        _buildDetailRow(
                                          "Permanent Addr:",
                                          app['permanent_address'],
                                        ),
                                        _buildDetailRow(
                                          "NID:",
                                          app['nid_number'],
                                        ),
                                        _buildDetailRow(
                                          "Gender:",
                                          app['gender'],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Bio:",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          app['bio'] ?? 'N/A',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Details"),
                          ),

                          // 2. Accept/Decline/Call Buttons
                          if (status == 'pending') ...[
                            ElevatedButton(
                              onPressed: () => _updateStatus(
                                appId,
                                'approved',
                                applicantName,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Accept"),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateStatus(
                                appId,
                                'declined',
                                applicantName,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decline"),
                            ),
                          ] else if (status == 'approved') ...[
                            ElevatedButton.icon(
                              onPressed: () => _callApplicant(applicantPhone),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text("Call Applicant"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],

                          // 3. ⚠️ Remove Button (New) - সব অবস্থায় দেখাবে
                          TextButton.icon(
                            onPressed: () => _removeApplication(appId),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            label: const Text(
                              "Remove",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    String displayValue = (value == null || value.trim().isEmpty)
        ? "N/A"
        : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(displayValue, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
