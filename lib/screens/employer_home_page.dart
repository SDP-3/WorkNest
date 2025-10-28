import 'package:flutter/material.dart'; // <<<--- ১. Ei line-ta add kora hoyeche
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // <<<--- ২. Provider import
import 'notification_provider.dart'; // <<<--- ৩. Provider file import (ekhn eki folder-e)
import 'login_screen.dart';
import 'employer_profile_page.dart';
import 'post_job_page.dart';
import 'job_applications_page.dart';
import 'customer_care_page.dart';
import 'notification_list_page.dart';

// ---------------------- EMPLOYER HOME PAGE ----------------------
// (Dhoche nicchi apnar shob file 'lib/screens/' folder-er vitore ache)

class EmployerHomePage extends StatelessWidget {
  final Map<String, String> userData;
  const EmployerHomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // ------- Top App Bar (Custom Container) -------
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
                              icon: const Icon(Icons.notifications_active_rounded,
                                  color: Colors.blue),
                              tooltip: "Notifications",
                              
                              // onPressed e count reset kora hocche
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
                            
                            // Consumer widget count dekhabe
                            Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                if (provider.unreadCount == 0) {
                                  return const SizedBox.shrink(); 
                                }
                                
                                return Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        provider.unreadCount.toString(), // Dynamic count
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
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

              const SizedBox(height: 25),
              Text(
                "Employer Dashboard",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),

              // ------------------ Grid items ------------------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    // Profile Item
                    _gridItem(
                      context,
                      Icons.person_outline_rounded,
                      "Profile",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployerProfilePage(
                              userData: userData,
                              onUpdate: (updatedUser) {
                                print("Profile update callback: $updatedUser");
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    // Post Job Item
                    _gridItem(
                      context,
                      Icons.post_add_rounded,
                      "Post Job",
                      () { 
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostJobPage(employerData: userData),
                          ),
                        );
                      },
                    ),
                    // Job Applications Item
                    _gridItem(
                      context,
                      Icons.assignment_ind_rounded,
                      "Job Applications",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobApplicationsPage(),
                          ),
                        );
                      },
                    ),
                    // Customer Care Item
                    _gridItem(
                      context,
                      Icons.support_agent_rounded,
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

              // ------- Logout button -------
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text("Log Out", style: GoogleFonts.poppins(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget
  Widget _gridItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue[800]),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
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