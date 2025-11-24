import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ❗️ সময় দেখানোর জন্য (flutter pub add intl)

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  // সময় ফরম্যাট করার ফাংশন
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM, hh:mm a').format(date); // যেমন: 12 Nov, 10:30 AM
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: const Center(child: Text("Please log in to see notifications")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // আপনার থিম কালার
      appBar: AppBar(
        title: Text(
          "All Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),

      // --- Firebase থেকে রিয়েল-টাইম ডেটা আনা ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where(
              'receiver_uid',
              isEqualTo: user.uid,
            ) // শুধু লগইন করা ইউজারের নোটিফিকেশন
            .orderBy('created_at', descending: true) // নতুনগুলো উপরে থাকবে
            .snapshots(),
        builder: (context, snapshot) {
          // ১. লোডিং অবস্থা
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // ২. যদি কোনো এরর হয়
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // ৩. যদি কোনো নোটিফিকেশন না থাকে
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No notifications yet.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // ৪. নোটিফিকেশন লিস্ট
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // ডেটা ভেরিয়েবলে নেওয়া
              String title = data['title'] ?? 'Notification';
              String body = data['body'] ?? '';
              String type = data['type'] ?? '';
              Timestamp? time = data['created_at'];

              // --- আইকন এবং কালার লজিক ---
              IconData icon = Icons.notifications;
              Color iconColor = Colors.blue;
              Color bgColor = Colors.white;

              if (type == 'approved') {
                icon = Icons.check_circle;
                iconColor = Colors.green;
                bgColor = Colors.green.withOpacity(0.1);
              } else if (type == 'declined') {
                icon = Icons.cancel;
                iconColor = Colors.red;
                bgColor = Colors.red.withOpacity(0.1);
              } else if (type == 'ban') {
                icon = Icons.warning_rounded;
                iconColor = Colors.red[900]!;
                bgColor = Colors.red[100]!;
              } else if (type == 'application_received') {
                icon = Icons.work;
                iconColor = Colors.purple;
                bgColor = Colors.purple.withOpacity(0.1);
              }

              // --- স্লাইড করে ডিলিট করার ফিচার (Dismissible) ---
              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart, // ডান থেকে বামে স্লাইড
                onDismissed: (direction) {
                  // Firebase থেকে ডিলিট করা
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(doc.id)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notification removed")),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: bgColor,
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(body, style: GoogleFonts.poppins(fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(time),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
