// lib/notification_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(
          "All Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              print("Notification $index tapped");
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: Colors.blue[800],
                ),
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
