import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import 'notification_provider.dart'; 
import 'login_screen.dart';
import 'job_seeker_profile_page.dart';
import 'job_board_page.dart';
import 'applied_jobs_page.dart';
import 'customer_care_page.dart';
import 'notification_list_page.dart'; // <<<--- Notification list page

// ---------------------- JOB SEEKER HOME PAGE ----------------------

class JobSeekerHomePage extends StatelessWidget {
  final String email;
  const JobSeekerHomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
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
                    Positioned(
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.blue),
                              
                              // <<<--- ৪. onPressed-e count reset kora hocche
                              onPressed: () {
                                Provider.of<NotificationProvider>(context, listen: false).resetCount();
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationListPage(),
                                  ),
                                );
                              },
                            ),

                            // <<<--- ৫. Consumer widget add kora holo
                            Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                // Jodi count 0 hoy, badge dekhabe na
                                if (provider.unreadCount == 0) {
                                  return const SizedBox.shrink(); 
                                }

                                // Count 0-er beshi hole badge dekhabe
                                return Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      provider.unreadCount.toString(), // <-- Dynamic count
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
                      () {
                        Map<String, String> userData = {
                          "email": email, 
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobSeekerProfilePage(
                              userData: userData,
                              onUpdate: (updatedUser) {},
                            ),
                          ),
                        );
                      },
                    ),
                    _gridItem(context, Icons.work, "Job Board", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JobBoardPage()),
                      );
                    }),
                    _gridItem(context, Icons.assignment_turned_in, "Applied Jobs", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppliedJobsPage()),
                      );
                    }),
                    _gridItem(context, Icons.support_agent, "Customer Care", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerCarePage()),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
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

  // Helper widget
  Widget _gridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
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