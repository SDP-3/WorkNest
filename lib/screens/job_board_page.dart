import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'applied_jobs_page.dart';

class JobBoardPage extends StatefulWidget {
  const JobBoardPage({super.key});

  @override
  State<JobBoardPage> createState() => _JobBoardPageState();
}

class _JobBoardPageState extends State<JobBoardPage> {
  // ১. জব লোড করার স্ট্রিম
  final Stream<QuerySnapshot> _jobsStream = FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('posted_at', descending: true)
      .snapshots();

  // --- ২. জব রিপোর্ট করার ফাংশন ---
  Future<void> _reportJob(
    String jobId,
    String jobTitle,
    String postedByUid,
  ) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? didConfirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Report Job?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why are you reporting "$jobTitle"?',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: "Enter reason (e.g. Fake job, Fraud)",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (didConfirm == true && mounted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        String finalReason = reasonController.text.trim();
        if (finalReason.isEmpty) {
          finalReason = "Job Seeker reported this as inappropriate";
        } else {
          finalReason = "Job Seeker Report: $finalReason";
        }

        await FirebaseFirestore.instance.collection('reports').add({
          'job_id': jobId,
          'job_title': jobTitle,
          'reported_at': FieldValue.serverTimestamp(),
          'reporter_uid': user?.uid,
          'reason': finalReason,
          'status': 'pending',
          'reported_uid': postedByUid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job reported successfully. Admin will review it.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- ৩. জব Apply করার ফাংশন (নোটিফিকেশন সহ) ---
  Future<void> _applyForJob(String jobId, Map<String, dynamic> jobData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to apply'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // ক. ডুপ্লিকেট চেক
      final existingApplication = await FirebaseFirestore.instance
          .collection('applications')
          .where('job_id', isEqualTo: jobId)
          .where('applicant_uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already applied for this job'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // খ. আবেদনকারীর ডেটা আনা
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists || userDoc.data() == null) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your profile first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final userData = userDoc.data() as Map<String, dynamic>;

      // গ. এমপ্লয়ারের ফোন নম্বর আনা
      String employerUid = jobData['posted_by_uid'];
      String employerPhone = "";
      try {
        DocumentSnapshot employerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(employerUid)
            .get();
        if (employerDoc.exists) {
          employerPhone = employerDoc.get('phone') ?? "";
        }
      } catch (e) {
        print("Error fetching employer phone: $e");
      }

      // ঘ. অ্যাপ্লিকেশন সেভ করা
      await FirebaseFirestore.instance.collection('applications').add({
        'job_id': jobId,
        'job_title': jobData['job_title'],
        'company_name': jobData['company_name'],
        'salary': jobData['salary'],
        'location': jobData['location'],
        'employer_uid': employerUid,
        'employer_phone': employerPhone,

        'applicant_uid': user.uid,
        'applicant_email': user.email,
        'applicant_name': userData['name'] ?? 'N/A',
        'applicant_phone': userData['phone'] ?? 'N/A',

        'father_name': userData['fatherName'] ?? 'N/A',
        'present_address': userData['presentAddress'] ?? 'N/A',
        'permanent_address': userData['permanentAddress'] ?? 'N/A',
        'nid_number': userData['nid'] ?? 'N/A',

        'gender': userData['gender'] ?? 'N/A',
        'bio': userData['bio'] ?? 'N/A',
        'applicant_location': userData['location'] ?? 'N/A',

        'applied_at': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // ঙ. ✅ এমপ্লয়ারের কাছে নোটিফিকেশন পাঠানো (NEW)
      await FirebaseFirestore.instance.collection('notifications').add({
        'receiver_uid': employerUid, // এমপ্লয়ারের আইডি
        'title': "New Application Received!",
        'body': "${userData['name']} applied for ${jobData['job_title']}",
        'type': 'application_received',
        'created_at': FieldValue.serverTimestamp(),
        'is_read': false,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Applied Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppliedJobsPage()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Job Board",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],

      body: StreamBuilder<QuerySnapshot>(
        stream: _jobsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No jobs posted yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              var job = document.data() as Map<String, dynamic>;
              String jobId = document.id;

              return Card(
                color: Colors.lightBlue[50],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['job_title'] ?? "No Title",
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${job['category'] ?? 'N/A'} - ${job['location'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Salary: ${job['salary'] ?? 'N/A'} | Type: ${job['job_type'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ১. Report Button
                          TextButton.icon(
                            onPressed: () {
                              _reportJob(
                                jobId,
                                job['job_title'] ?? 'N/A',
                                job['posted_by_uid'] ?? '',
                              );
                            },
                            icon: const Icon(
                              Icons.flag_outlined,
                              size: 18,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Report",
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // ২. Details Button
                          OutlinedButton(
                            onPressed: () {
                              _showJobDetails(context, job);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[900],
                              side: BorderSide(color: Colors.blue[900]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Details",
                              style: GoogleFonts.poppins(),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ৩. Apply Button
                          ElevatedButton(
                            onPressed: () {
                              _applyForJob(jobId, job);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                69,
                                202,
                                98,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text("Apply", style: GoogleFonts.poppins()),
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

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            job['job_title'] ?? "",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Category:", job['category']),
                _detailRow("Location:", job['location']),
                _detailRow("Salary:", job['salary']),
                _detailRow("Job Type:", job['job_type']),
                const Divider(),
                Text(
                  "Description:",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                Text(job['description'] ?? "N/A", style: GoogleFonts.poppins()),
                const SizedBox(height: 10),
                Text(
                  "Requirements:",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                Text(
                  job['requirements'] ?? "N/A",
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 10),
                _detailRow("Company:", job['company_name']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            "$label ",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value ?? "N/A", style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
}
