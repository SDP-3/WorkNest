import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// ---------------------- CUSTOMER CARE PAGE ----------------------

class CustomerCarePage extends StatelessWidget {
  const CustomerCarePage({super.key});

  // Helper function to launch URLs (like tel:, mailto:)
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Show an error message if the URL can't be launched
      if (context.mounted) { // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $url")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Very light blue background
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Dark blue app bar
        foregroundColor: Colors.white, // White title and back arrow
        title: Text(
          "Customer Care",
          style: GoogleFonts.poppins( // Use GoogleFonts
              color: Colors.white, fontWeight: FontWeight.w600), // Bold title
        ),
        elevation: 0, // No shadow
      ),
      body: SingleChildScrollView( // Allows scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
            children: [
              const SizedBox(height: 20),

              // Header Icon
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100], // Light blue circle
                child: Icon(Icons.support_agent_rounded, // Rounded icon
                    size: 60, color: Colors.blue[800]), // Darker blue icon
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "We’re Here to Help!",
                style: GoogleFonts.poppins( // Use GoogleFonts
                  fontSize: 24, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900], // Dark blue text
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle description
              Text(
                "Our customer care representatives are available 24/7\nto assist you with any job-related queries.",
                textAlign: TextAlign.center, // Center align text
                style: GoogleFonts.poppins( // Use GoogleFonts
                    fontSize: 15, color: Colors.black54, height: 1.4), // Line height
              ),

              const SizedBox(height: 40), // Increased spacing

              // Contact Options section
              _contactOption(
                context,
                icon: Icons.call_rounded, // Rounded icon
                title: "Call Us",
                subtitle: "+880 1234 567 890", // Example number
                color: Colors.green[600]!, // Slightly darker green
                onTap: () {
                  _launchURL(context, "tel:+8801234567890"); // Launch dialer
                },
              ),
              const SizedBox(height: 15),
              _contactOption(
                context,
                icon: Icons.email_rounded, // Rounded icon
                title: "Email Us",
                subtitle: "support@worknest.com", // Example email
                color: Colors.orange[600]!, // Slightly darker orange
                onTap: () {
                  _launchURL(context, "mailto:support@worknest.com"); // Launch email client
                },
              ),
              const SizedBox(height: 15),
              _contactOption(
                context,
                icon: Icons.chat_bubble_rounded, // Rounded icon
                title: "Live Chat",
                subtitle: "Connect instantly with CCR",
                color: Colors.blue[600]!, // Standard blue
                onTap: () {
                  // Placeholder for live chat functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Live chat feature coming soon!")),
                  );
                },
              ),

              const SizedBox(height: 40), // Increased spacing

              // Extra Informational Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Light blue background
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(color: Colors.blue[100]!), // Light blue border
                  boxShadow: [ // Subtle shadow
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
                    Icon(Icons.info_outline_rounded, color: Colors.blue[800]), // Info icon
                    const SizedBox(width: 10),
                    Expanded( // Makes text wrap
                      child: Text(
                        "Our CCR team can connect you with employers and job seekers directly via phone calls for smooth communication.",
                        style: GoogleFonts.poppins( // Use GoogleFonts
                            fontSize: 14, color: Colors.black87, height: 1.3), // Line height
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Added bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for creating styled contact option list tiles
  Widget _contactOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell( // Makes the whole container tappable with ripple effect
      onTap: onTap,
      borderRadius: BorderRadius.circular(15), // Ripple matches container shape
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // White background for the card
          borderRadius: BorderRadius.circular(15),
          boxShadow: [ // Standard card shadow
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
            // Circular icon background
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1), // Lighter background color
              child: Icon(icon, size: 28, color: color), // Icon with specified color
            ),
            const SizedBox(width: 15),
            // Title and Subtitle text column
            Expanded( // Allows text to wrap if needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins( // Use GoogleFonts
                      fontSize: 17, // Slightly larger title
                      fontWeight: FontWeight.w600, // Semi-bold
                      color: Colors.blue[900], // Dark blue title text
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins( // Use GoogleFonts
                      fontSize: 14,
                      color: Colors.black54), // Grey subtitle text
                    overflow: TextOverflow.ellipsis, // Prevent long subtitles from overflowing
                  ),
                ],
              ),
            ),
            // Optional: Add a chevron icon to indicate tappable item
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}