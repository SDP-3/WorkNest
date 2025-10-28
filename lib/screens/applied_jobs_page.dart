import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// ---------------------- APPLIED JOBS PAGE ----------------------

class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({super.key});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  // Sample data is removed. Data should be fetched from backend.
  List<Map<String, dynamic>> appliedJobs = []; // Start with an empty list

  // Customer Care Representative (CCR) phone number (replace with actual number)
  final String ccrNumber = "tel:+8801XXXXXXXXX";

  // Function to launch the phone dialer
  Future<void> _callCCR() async {
    final Uri ccrUri = Uri.parse(ccrNumber);
    if (await canLaunchUrl(ccrUri)) {
      await launchUrl(ccrUri);
    } else {
      // Show error if the call cannot be initiated
      if (mounted) { // Check if the widget is still in the tree
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Could not launch $ccrNumber")),
         );
      }
    }
  }

  // Function to handle cancelling an application
  void _cancelApplication(int index) {
    // TODO: Add backend logic here to actually cancel the application in the database.
    setState(() {
      // Temporarily remove the job from the UI list for immediate feedback
      appliedJobs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Application cancelled (Backend Pending)")),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: Fetch applied jobs data from backend here, perhaps in initState or using FutureBuilder

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // Background color for the page
      appBar: AppBar(
        title: Text(
          "Applied Jobs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900], // Dark blue app bar
        foregroundColor: Colors.white, // White color for back arrow and title
        centerTitle: true,
        elevation: 0, // No shadow for a flatter look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Display a message if the list of applied jobs is empty
        child: appliedJobs.isEmpty
            ? Center(
                child: Text(
                  "You have not applied for any jobs yet.",
                  style: GoogleFonts.poppins( // Use GoogleFonts
                      fontSize: 16, color: Colors.white70), // Slightly muted text color
                  textAlign: TextAlign.center,
                ),
              )
            // Otherwise, display the list of applied jobs
            : ListView.builder(
                itemCount: appliedJobs.length,
                itemBuilder: (context, index) {
                  final job = appliedJobs[index];
                  // Card UI for each applied job
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    color: Colors.blue[100], // Light blue card background
                    elevation: 4, // Shadow effect
                    margin: const EdgeInsets.symmetric(vertical: 10), // Spacing between cards
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                        children: [
                          // Job title
                          Text(
                            job["title"] ?? "N/A", // Use ?? for null safety
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900], // Dark blue text
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Company name
                          Text(
                            job["company"] ?? "N/A", // Use ?? for null safety
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87, // Slightly lighter black
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Row containing Status and Cancel button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out elements
                            children: [
                              // Display the application status using a helper widget
                              _buildStatus(job["status"] ?? "Pending"), // Pass status, default to Pending
                              const SizedBox(width: 10),

                              // Cancel button
                              ElevatedButton(
                                onPressed: () => _cancelApplication(index), // Call cancel function
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent, // Red color for cancel
                                  foregroundColor: Colors.white, // White text
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Button padding
                                ),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),

                          // Conditionally display the "Contact via CCR" button if approved
                          if (job["status"] == "Approved") ...[
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _callCCR, // Call the CCR function
                              icon: const Icon(Icons.phone, color: Colors.white, size: 18), // Phone icon
                              label: Text(
                                  "Contact via CCR",
                                  style: GoogleFonts.poppins(fontSize: 14) // Consistent font
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Green color for contact
                                foregroundColor: Colors.white, // White text and icon
                                minimumSize: const Size(double.infinity, 45), // Full width button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Helper widget to display status with appropriate icon and color
  Widget _buildStatus(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) { // Use toLowerCase for case-insensitivity
      case "approved":
        statusColor = Colors.green[700]!; // Darker green
        statusIcon = Icons.check_circle_outline; // Outline icon
        statusText = "Approved";
        break;
      case "declined":
      case "cancelled": // Handle both declined and cancelled
        statusColor = Colors.red[700]!; // Darker red
        statusIcon = Icons.highlight_off; // Different icon for negative status
        statusText = status; // Display "Declined" or "Cancelled"
        break;
      default: // Default case for "Pending" or any unknown status
        statusColor = Colors.orange[700]!; // Darker orange
        statusIcon = Icons.hourglass_empty_outlined; // Outline icon
        statusText = "Pending";
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 20), // Icon size
        const SizedBox(width: 6),
        Text(
          statusText,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600, // Bold weight
            color: statusColor,
          ),
        ),
      ],
    );
  }
}