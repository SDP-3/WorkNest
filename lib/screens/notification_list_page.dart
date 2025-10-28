// lib/notification_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // আপনার থিমের সাথে মিল রেখে
      appBar: AppBar(
        title: Text(
          "All Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900], // আপনার থিমের সাথে মিল রেখে
        // AppBar নিজে থেকেই back button অ্যাড করে নেবে
      ),
      body: ListView.builder(
        itemCount: 10, // আপাতত ১০টা ডেমো নোটিফিকেশন
        itemBuilder: (context, index) {
          // এই ListTile টাকেই আমরা InkWell দিয়েছিলাম
          return InkWell(
            onTap: () {
              // এখানে চাপ দিলে নোটিফিকেশনের বিস্তারিত পেজে যাবে
              // (আপাতত কিছু করার দরকার নেই)
              print("Notification $index tapped");
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Icon(Icons.notifications_active, color: Colors.blue[800]),
                title: Text(
                  "Notification Title ${index + 1}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "This is the detail for notification number ${index + 1}...",
                  style: GoogleFonts.poppins(),
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }
}