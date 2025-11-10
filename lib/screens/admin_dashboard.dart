import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedItem = 'Dashboard';

  void _changePage(String pageName) {
    setState(() {
      _selectedItem = pageName;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedItem != 'Dashboard') {
      setState(() {
        _selectedItem = 'Dashboard';
      });
      return false;
    }
    return true;
  }

  Widget _getBodyContent() {
    switch (_selectedItem) {
      case 'Dashboard':
        return AdminDashboardHome(onPageChange: _changePage);
      case 'Users':
        return const AdminUserManagement();
      case 'Jobs':
        return const AdminJobManagement();
      case 'Support Chat':
        return const AdminSupportChat();
      case 'Reports':
         return const AdminReportsPage(); // নতুন রিপোর্ট পেজ যুক্ত করা হলো
      default:
        return const Center(child: Text("Welcome Admin"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedItem, style: GoogleFonts.poppins()),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          leading: _selectedItem == 'Dashboard'
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedItem = 'Dashboard';
                    });
                  },
                ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[900]),
                accountName: Text("WorkNest Admin", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text("admin@worknest.com", style: GoogleFonts.poppins()),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.dashboard_rounded, 'Dashboard'),
                    _buildDrawerItem(Icons.people_alt_rounded, 'Users'),
                    _buildDrawerItem(Icons.work_rounded, 'Jobs'),
                    _buildDrawerItem(Icons.warning_amber_rounded, 'Reports'),
                    _buildDrawerItem(Icons.chat_bubble_rounded, 'Support Chat'),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text('Log Out', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        body: _getBodyContent(),
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    bool isSelected = _selectedItem == title;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue[900] : Colors.grey[700]),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.blue[900] : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        onTap: () {
          setState(() => _selectedItem = title);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Log Out", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to log out?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Log Out", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==================== 1. DASHBOARD HOME ====================
class AdminDashboardHome extends StatelessWidget {
  final Function(String) onPageChange;
  const AdminDashboardHome({super.key, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Overview", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          const SizedBox(height: 20),
          Row(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  String count = snapshot.hasData ? "${snapshot.data!.docs.length}" : "...";
                  return _buildStatCard("Total Users", count, Icons.group, Colors.blue, onTap: () => onPageChange('Users'));
                },
              ),
              const SizedBox(width: 15),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                builder: (context, snapshot) {
                  String count = snapshot.hasData ? "${snapshot.data!.docs.length}" : "...";
                  return _buildStatCard("Active Jobs", count, Icons.work, Colors.green, onTap: () => onPageChange('Jobs'));
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
               // REAL REPORT COUNT
               StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reports').where('status', isEqualTo: 'pending').snapshots(),
                builder: (context, snapshot) {
                  String count = snapshot.hasData ? "${snapshot.data!.docs.length}" : "0";
                  return _buildStatCard("Pending Reports", count, Icons.warning_amber_rounded, Colors.orange, onTap: () => onPageChange('Reports'));
                },
              ),
              const SizedBox(width: 15),
              _buildStatCard("Today's Signups", "0", Icons.person_add, Colors.purple, onTap: () => onPageChange('Users')),
            ],
          ),
          const SizedBox(height: 30),
          Text("Recent Users Activity", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text("No recent activity.");
              return Column(
                children: docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.person_outline, color: Colors.blue[900]),
                      title: Text("New user: ${data['name'] ?? data['email'] ?? 'Unknown'}", style: GoogleFonts.poppins()),
                      subtitle: Text(data['userType'] ?? 'N/A', style: GoogleFonts.poppins(fontSize: 12)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, {required VoidCallback onTap}) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(height: 15),
                Text(count, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(title, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 2. USER MANAGEMENT ====================
class AdminUserManagement extends StatelessWidget {
  const AdminUserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Something went wrong!"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        var users = snapshot.data!.docs;
        if (users.isEmpty) return const Center(child: Text("No users found."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userData = users[index].data() as Map<String, dynamic>;
            String userType = userData['userType'] ?? 'Unknown';
            bool isBlocked = userData['isBlocked'] == true; // চেক করা হচ্ছে ইউজার ব্লকড কিনা

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              // ব্লকড হলে লালচে ব্যাকগ্রাউন্ড দেখাবে
              color: isBlocked ? Colors.red[50] : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: userType == 'employer' ? Colors.purple[100] : Colors.blue[100],
                  child: Icon(userType == 'employer' ? Icons.business : Icons.person, color: userType == 'employer' ? Colors.purple : Colors.blue[900]),
                ),
                title: Text(userData['name'] ?? 'No Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text("${userData['email'] ?? 'No Email'} \nRole: $userType ${isBlocked ? '(BANNED)' : ''}", 
                  style: GoogleFonts.poppins(color: isBlocked ? Colors.red : Colors.grey[700], fontSize: 13)),
                isThreeLine: true,
                trailing: isBlocked 
                  ? const Icon(Icons.block, color: Colors.red) // ব্লকড হলে আইকন দেখাবে
                  : PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text("View Details")),
                    ],
                  ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== 3. JOB MANAGEMENT ====================
class AdminJobManagement extends StatelessWidget {
  const AdminJobManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').orderBy('posted_at', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error loading jobs"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        var jobs = snapshot.data!.docs;
        if (jobs.isEmpty) return const Center(child: Text("No jobs posted yet."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var jobData = jobs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(jobData['job_title'] ?? 'No Title', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    const SizedBox(height: 5),
                    Text("Company: ${jobData['company_name'] ?? 'N/A'}", style: GoogleFonts.poppins(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                    Text("Location: ${jobData['location'] ?? 'N/A'}", style: GoogleFonts.poppins(color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Chip(label: Text(jobData['category'] ?? 'Job', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)), backgroundColor: Colors.blue[300]),
                        OutlinedButton.icon(
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text("Are you sure you want to delete this job post?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ) ?? false;
                            if (confirm) {
                              await FirebaseFirestore.instance.collection('jobs').doc(jobs[index].id).delete();
                              if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job deleted successfully")));
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          label: Text("Delete", style: GoogleFonts.poppins(color: Colors.red)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== 4. REPORTS PAGE (NEW & FUNCTIONAL) ====================
class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // শুধু 'pending' স্ট্যাটাসের রিপোর্টগুলো আনা হচ্ছে
      stream: FirebaseFirestore.instance.collection('reports').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error loading reports"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        var reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                const SizedBox(height: 20),
                Text("No pending reports!", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            var reportData = reports[index].data() as Map<String, dynamic>;
            String reportId = reports[index].id;
            String reportedUid = reportData['reported_uid'] ?? '';
            String reason = reportData['reason'] ?? 'No reason provided';

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                        const SizedBox(width: 10),
                        Text("Report Against User", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Text("Reason:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    Text(reason, style: GoogleFonts.poppins(fontSize: 15)),
                    const SizedBox(height: 10),
                    Text("Reported User ID:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    SelectableText(reportedUid, style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey)), // কপি করার সুবিধার জন্য SelectableText
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // IGNORE BUTTON
                        TextButton(
                          onPressed: () async {
                            // রিপোর্ট ইগনোর করলে শুধু স্ট্যাটাস চেঞ্জ হবে
                            await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'status': 'ignored'});
                            if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report ignored")));
                          },
                          child: Text("Ignore", style: GoogleFonts.poppins(color: Colors.grey)),
                        ),
                        const SizedBox(width: 10),
                        // BAN USER BUTTON
                        ElevatedButton.icon(
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Ban"),
                                content: const Text("Are you sure you want to PERMANENTLY BAN this user? They won't be able to login anymore."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("BAN USER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ) ?? false;

                            if (confirm && reportedUid.isNotEmpty) {
                              // ১. ইউজারকে ব্যান করা (isBlocked: true সেট করা)
                              await FirebaseFirestore.instance.collection('users').doc(reportedUid).update({'isBlocked': true});
                              // ২. রিপোর্টটি রিজলভ করে দেওয়া
                              await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'status': 'resolved'});
                              
                              if(context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("User has been BANNED successfully"), backgroundColor: Colors.redAccent)
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.block, size: 18),
                          label: Text("BAN USER", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== 5. SUPPORT CHAT (PLACEHOLDER) ====================
class AdminSupportChat extends StatelessWidget {
  const AdminSupportChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("Support Chat System coming next!", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}