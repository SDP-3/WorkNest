// screens/applied_jobs_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({super.key});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  Stream<QuerySnapshot>? _applicationsStream;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      // এই ইউজারের সব অ্যাপ্লিকেশন লাইভ লোড করা হচ্ছে
      _applicationsStream = FirebaseFirestore.instance
          .collection('applications')
          .where('applicant_uid', isEqualTo: _user!.uid)
          .orderBy('applied_at', descending: true)
          .snapshots();
    }
  }

  // স্ট্যাটাস অনুযায়ী রং ঠিক করার ফাংশন
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.orange; // Pending
    }
  }

  // --- ডায়নামিক নম্বরে কল করার ফাংশন ---
  Future<void> _callEmployer(String? phoneNumber) async {
    // ১. নম্বর আছে কি না চেক করা
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == "N/A") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Employer phone number is missing in database!"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ২. নম্বরটি ডিবাগিং-এর জন্য দেখানো
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Calling: $phoneNumber..."),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // ৩. কল লঞ্চ করা
    final Uri callUri = Uri.parse("tel:$phoneNumber");
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        throw "Could not launch";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not dial $phoneNumber. Error: $e")),
        );
      }
    }
  }

  // আবেদন বাতিল বা রিমুভ করার ফাংশন
  Future<void> _cancelApplication(String docId, String status) async {
    String actionText = status == 'pending' ? "Cancel" : "Remove";

    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("$actionText Application?"),
            content: Text(
              "Are you sure you want to $actionText this application from your list?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text(
          "My Applied Jobs",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          // লোডিং অবস্থা
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // যদি কোনো এরর থাকে
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // যদি কোনো আবেদন না থাকে
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You haven't applied for any jobs yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // লিস্ট দেখানো
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // স্ট্যাটাস ছোট হাতের অক্ষরে নেওয়া
              String status = (data['status'] ?? 'pending')
                  .toString()
                  .toLowerCase();
              String displayStatus =
                  status[0].toUpperCase() + status.substring(1);
              String employerPhone = data['employer_phone'] ?? '';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- জব টাইটেল এবং স্ট্যাটাস ব্যাজ ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['job_title'] ?? 'Unknown Job',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(status),
                              ),
                            ),
                            child: Text(
                              displayStatus,
                              style: GoogleFonts.poppins(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // --- কোম্পানির নাম ---
                      Text(
                        data['company_name'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --- একশন বাটন ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ১. Contact Button (শুধুমাত্র Approved হলে দেখাবে)
                          if (status == 'approved')
                            ElevatedButton.icon(
                              onPressed: () => _callEmployer(employerPhone),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text("Contact"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            ),

                          const SizedBox(width: 8),

                          // ২. Cancel/Remove Button (সব সময়ই দেখাবে)
                          // যাতে ইউজার পুরনো বা অপ্রয়োজনীয় কার্ড ডিলিট করতে পারে
                          TextButton.icon(
                            onPressed: () => _cancelApplication(doc.id, status),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            label: Text(
                              status == 'pending'
                                  ? "Cancel"
                                  : "Remove", // টেক্সট পরিবর্তন হবে স্ট্যাটাস অনুযায়ী
                              style: const TextStyle(color: Colors.red),
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
}
