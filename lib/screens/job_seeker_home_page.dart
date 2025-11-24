import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_provider.dart';
import 'login_screen.dart';
import 'job_seeker_profile_page.dart';
import 'job_board_page.dart';
import 'applied_jobs_page.dart';
import 'customer_care_page.dart';
import 'notification_list_page.dart';

class JobSeekerHomePage extends StatefulWidget {
  final String email;
  const JobSeekerHomePage({super.key, required this.email});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ⚠️ পরিবর্তন ১: এখানে শুধু unread মেসেজগুলো শোনা হচ্ছে
      FirebaseFirestore.instance
          .collection('notifications')
          .where('receiver_uid', isEqualTo: user.uid)
          .where('is_read', isEqualTo: false) // <-- শুধু না পড়া মেসেজগুলো গুনবে
          .snapshots()
          .listen((snapshot) {
            if (mounted) {
              Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).setUnreadCount(snapshot.docs.length);
            }
          });
    }
  }

  // ⚠️ পরিবর্তন ২: নোটিফিকেশন সিন (Seen) করার ফাংশন
  Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ১. সব unread নোটিফিকেশন খুঁজে বের করা
      var snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiver_uid', isEqualTo: user.uid)
          .where('is_read', isEqualTo: false)
          .get();

      // ২. এক এক করে সবগুলোকে read করে দেওয়া
      for (var doc in snapshot.docs) {
        doc.reference.update({'is_read': true});
      }

      // ৩. লোকাল কাউন্ট ০ করে দেওয়া (দ্রুত রেসপন্সের জন্য)
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).resetCount();
      }
    }
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          if (mounted) Navigator.pop(context);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobSeekerProfilePage(
                  userData: {
                    'uid': user.uid,
                    'email': data['email'] ?? widget.email,
                    'name': data['name'] ?? "",
                    'phone': data['phone'] ?? "",
                    'fatherName': data['fatherName'] ?? "",
                    'presentAddress': data['presentAddress'] ?? "",
                    'permanentAddress': data['permanentAddress'] ?? "",
                    'nid': data['nid'] ?? "",
                    'location': data['location'] ?? "",
                    'gender': data['gender'] ?? "",
                    'userType': data['userType'] ?? "jobSeeker",
                    'imagePath': data['imagePath'] ?? "",
                    'bio': data['bio'] ?? "",
                  },
                  onUpdate: (updatedData) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update(updatedData);
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // --- HEADER SECTION ---
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        "HOME",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // --- নোটিফিকেশন আইকন ---
                    Positioned(
                      right: 0,
                      child: Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    // ⚠️ পরিবর্তন ৩: ক্লিক করলেই সব 'Read' হয়ে যাবে
                                    _markNotificationsAsRead();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationListPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (provider.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${provider.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Job Seeker",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // --- GRID MENU ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: [
                    _gridItem(
                      context,
                      Icons.person,
                      "Profile",
                      () => _navigateToProfile(context),
                    ),
                    _gridItem(context, Icons.work, "Job Board", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobBoardPage(),
                        ),
                      );
                    }),
                    _gridItem(
                      context,
                      Icons.assignment_turned_in,
                      "Applied Jobs",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppliedJobsPage(),
                          ),
                        );
                      },
                    ),
                    _gridItem(
                      context,
                      Icons.support_agent,
                      "Customer Care",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerCarePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- LOGOUT BUTTON ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue[900]),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
