import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPostedJobsPage extends StatelessWidget {
  const MyPostedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // বর্তমান লগ-ইন করা ইউজারের ID নিচ্ছি
    final user = FirebaseAuth.instance.currentUser;

    // যদি ইউজার লগ-ইন না থাকে, তবে এরর মেসেজ দেখাবে
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Posted Jobs")),
        body: const Center(child: Text("Please log in to see your posted jobs.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Posted Jobs", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // এখানে আমরা কুয়েরি করছি: 'jobs' কালেকশন থেকে শুধু সেই ডকুমেন্টগুলো আনো
        // যেখানে 'posted_by_uid' ফিল্ডটি বর্তমান ইউজারের UID-এর সমান।
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('posted_by_uid', isEqualTo: user.uid)
            .orderBy('posted_at', descending: true) // নতুনগুলো আগে দেখাবে
            .snapshots(),
        builder: (context, snapshot) {
          // ডেটা লোড হচ্ছে কিনা চেক করা
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // কোনো এরর হলে দেখানো
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // যদি কোনো জব না থাকে
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You haven't posted any jobs yet.",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // জবগুলোর লিস্ট দেখানো
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var jobData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              // ডকুমেন্টের ID-টাও আমরা রাখতে পারি যদি পরে এডিট/ডিলিট করতে হয়
              // String jobId = snapshot.data!.docs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobData['job_title'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${jobData['category']} • ${jobData['job_type']}",
                         style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                       Text(
                        "Salary: ${jobData['salary']}",
                         style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                       const SizedBox(height: 8),
                      Text(
                        "Posted on: ${_formatDate(jobData['posted_at'])}",
                         style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
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

  // টাইমস্ট্যাম্প থেকে সুন্দর তারিখ দেখানোর জন্য একটি ছোট ফাংশন
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return "N/A";
  }
}