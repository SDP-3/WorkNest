import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ---------------------- CUSTOMER CARE PAGE ----------------------

class CustomerCarePage extends StatefulWidget {
  const CustomerCarePage({super.key});

  @override
  State<CustomerCarePage> createState() => _CustomerCarePageState();
}

class _CustomerCarePageState extends State<CustomerCarePage> {
  bool _isChatActive = false;
  final TextEditingController _messageController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+8801700000000');
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch dialer';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _sendEmail() async {
    final String email = 'support@worknest.com';
    final String subject = 'Support Request';
    final String body = 'Hello WorkNest Team,';

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open email app.")),
        );
      }
    }
  }

  // --- ৩. মেসেজ পাঠানোর ফাংশন (🔥 আপডেটেড: নাম সহ) ---
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (user == null) return;

    String message = _messageController.text.trim();
    _messageController.clear();

    // ⚠️ নাম খুঁজে বের করা (NEW)
    String userName = user!.displayName ?? "User";
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        userName = userDoc.get('name') ?? userName;
      }
    } catch (e) {
      print("Error fetching name: $e");
    }

    // ১. মেসেজ সেভ করা
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(user!.uid)
        .collection('messages')
        .add({
          'text': message,
          'sender_id': user!.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'is_admin': false,
        });

    // ২. চ্যাট লিস্ট আপডেট করা (⚠️ এখানে 'user_name' যোগ করা হয়েছে)
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(user!.uid)
        .set({
          'last_message': message,
          'last_time': FieldValue.serverTimestamp(),
          'user_email': user!.email,
          'user_uid': user!.uid,
          'user_name': userName, // <--- এই লাইনটি নতুন
        }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isChatActive) {
          setState(() => _isChatActive = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          title: Text(
            _isChatActive ? "Live Support" : "Customer Care",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          leading: _isChatActive
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isChatActive = false),
                )
              : null,
        ),

        body: _isChatActive ? _buildChatInterface() : _buildMenuInterface(),
      ),
    );
  }

  // ------------------ MENU INTERFACE ------------------
  Widget _buildMenuInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.support_agent_rounded,
                size: 60,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "We’re Here to Help!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Our customer care representatives are available 24/7\nto assist you with any job-related queries.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),

            _contactOption(
              icon: Icons.call_rounded,
              title: "Call Us",
              subtitle: "+880 1700 000 000",
              color: Colors.green[600]!,
              onTap: _makePhoneCall,
            ),
            const SizedBox(height: 15),
            _contactOption(
              icon: Icons.email_rounded,
              title: "Email Us",
              subtitle: "support@worknest.com",
              color: Colors.orange[600]!,
              onTap: _sendEmail,
            ),
            const SizedBox(height: 15),

            _contactOption(
              icon: Icons.chat_bubble_rounded,
              title: "Live Chat",
              subtitle: "Connect instantly with CCR",
              color: Colors.blue[600]!,
              onTap: () {
                if (user != null) {
                  setState(() => _isChatActive = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please login to chat")),
                  );
                }
              },
            ),

            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[100]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue[800]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Our CCR team can connect you with employers and job seekers directly via phone calls for smooth communication.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------ CHAT INTERFACE ------------------
  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('support_chats')
                .doc(user!.uid)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              var messages = snapshot.data!.docs;
              if (messages.isEmpty)
                return Center(
                  child: Text(
                    "Start a conversation...",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                );

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var msg = messages[index].data() as Map<String, dynamic>;
                  bool isAdmin = msg['is_admin'] == true;

                  return Align(
                    alignment: isAdmin
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.white : Colors.blue[600],
                        borderRadius: BorderRadius.circular(12).copyWith(
                          bottomLeft: isAdmin ? Radius.zero : null,
                          bottomRight: !isAdmin ? Radius.zero : null,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 2),
                        ],
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: GoogleFonts.poppins(
                          color: isAdmin ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.blue[900],
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
