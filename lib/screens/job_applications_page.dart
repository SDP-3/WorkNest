import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ❗️ এই Import টি জরুরি

// ---------------------- EMPLOYER JOB APPLICATIONS PAGE ----------------------

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({super.key});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  // Sample data is removed. Data should be fetched from backend.
  List<Map<String, dynamic>> jobApplications = []; // Start with an empty list

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch job applications data from backend here

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // Background color
      appBar: AppBar(
        title: Text(
          "Job Applications",
          style: GoogleFonts.poppins(),
        ), // Consistent font
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Display a message if the list is empty
        child: jobApplications.isEmpty
            ? Center(
                child: Text(
                  "No applications received yet.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            // Otherwise, display the list of applications
            : ListView.builder(
                itemCount: jobApplications.length,
                itemBuilder: (context, index) {
                  final application = jobApplications[index];
                  Color statusColor;
                  IconData statusIcon;
                  String statusText =
                      application['status'] ?? "Pending"; // Default to Pending

                  // Determine color and icon based on status
                  switch (statusText.toLowerCase()) {
                    case 'approved':
                      statusColor = Colors.green[700]!;
                      statusIcon = Icons.check_circle_outline;
                      break;
                    case 'cancelled':
                    case 'declined':
                      statusColor = Colors.red[700]!;
                      statusIcon = Icons.highlight_off;
                      break;
                    default: // Pending or unknown
                      statusColor = Colors.orange[700]!;
                      statusIcon = Icons.hourglass_empty_outlined;
                      statusText =
                          "Pending"; // Ensure display text is consistent
                  }

                  // Card UI for each application
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          Text(
                            application['jobTitle'] ?? "N/A",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Row with Applicant Name and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Applicant Name
                              Expanded(
                                // Allow name to wrap if long
                                child: Text(
                                  "Applicant: ${application['applicantName'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Status Display
                              Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Prevent row from taking full width
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                      fontSize: 15,
                                    ), // Slightly smaller status font
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // Increased spacing
                          // Row with Action Buttons (Details, Approve/Decline/CCR Call)
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .end, // Align buttons to the right
                            children: [
                              // Details Button
                              OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      // Default values for safety
                                      final email =
                                          application['email'] ?? 'N/A';
                                      final phone =
                                          application['phone'] ?? 'N/A';
                                      final father =
                                          application['father'] ?? 'N/A';
                                      final presentAddress =
                                          application['presentAddress'] ??
                                          'N/A';
                                      final permanentAddress =
                                          application['permanentAddress'] ??
                                          'N/A';
                                      final nid = application['nid'] ?? 'N/A';
                                      final gender =
                                          application['gender'] ?? 'N/A';
                                      final location =
                                          application['location'] ?? 'N/A';
                                      final bio =
                                          application['bio'] ??
                                          'No bio provided.';

                                      return AlertDialog(
                                        title: Text(
                                          application['applicantName'] ??
                                              'Applicant Details',
                                          style: GoogleFonts.poppins(),
                                        ), // Add font
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            // Use ListBody for better structure
                                            children: <Widget>[
                                              _buildDetailRow(
                                                "Email:",
                                                email,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Phone:",
                                                phone,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Father:",
                                                father,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Present Addr:",
                                                presentAddress,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Permanent Addr:",
                                                permanentAddress,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "NID:",
                                                nid,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Gender:",
                                                gender,
                                              ), // Use helper
                                              _buildDetailRow(
                                                "Location:",
                                                location,
                                              ), // Use helper
                                              const SizedBox(height: 8),
                                              Text(
                                                "Bio:",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                bio,
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              "Close",
                                              style: GoogleFonts.poppins(),
                                            ), // Add font
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ), // Padding
                                ),
                                child: Text(
                                  "Details",
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Conditional Buttons based on status
                              if (statusText == 'Pending') ...[
                                // Approve Button
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Add backend logic to update status to 'Approved'
                                    setState(() {
                                      application['status'] =
                                          'Approved'; // Update UI immediately
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${application['applicantName']} approved! CCR will contact.",
                                        ), // Updated message
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    "Approve",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Decline Button
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Add backend logic to update status to 'Declined'
                                    setState(() {
                                      application['status'] =
                                          'Declined'; // Update UI immediately
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${application['applicantName']}'s application declined.",
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    "Decline",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ] else if (statusText == 'Approved') ...[
                                // CCR Call Button (if approved)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // ❗ applicantPhone variable removed here
                                    // TODO: Implement logic to notify CCR via backend API
                                    // For now, just show a message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Notifying CCR to connect with ${application['applicantName'] ?? 'applicant'}",
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.headset_mic_rounded,
                                    size: 18,
                                  ), // Changed Icon
                                  label: Text(
                                    "Request CCR Call",
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ), // Changed label
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .blue[800], // Slightly lighter blue
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ), // Padding
                                  ),
                                ),
                              ], // Add cases for Declined/Cancelled if needed (e.g., delete application?)
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
}
