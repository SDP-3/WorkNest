import 'package:flutter/material.dart';
import '../widgets/hover_button.dart'; // <--- Make sure this import is here

// ---------------------- JOB BOARD PAGE ----------------------

class JobBoardPage extends StatelessWidget {
  const JobBoardPage({super.key});

  // Sample data is removed.

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch jobs from your backend here
    final List<Map<String, String>> jobs = []; // Currently an empty list

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Board"),
        backgroundColor: Colors.blue[900],
      ),
      backgroundColor: Colors.grey[100],
      // Show a message if there are no jobs
      body: jobs.isEmpty
          ? const Center(
              child: Text(
                "No jobs posted yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  color: Colors.lightBlue[100],
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? "",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("${job['category']} - ${job['location']}"),
                        const SizedBox(height: 6),
                        Text(
                            "Salary: ${job['salary']} | Type: ${job['jobType']}"),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Apply Button with hover
                            HoverButton( // Use the custom widget
                              onPressed: () {
                                // TODO: Add backend logic to apply for the job
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Applied for ${job['title']} (Backend Pending)")),
                                );
                              },
                              text: "Apply",
                              backgroundColor:
                                  const Color.fromARGB(255, 69, 202, 98),
                              hoverColor:
                                  const Color.fromARGB(255, 52, 180, 75),
                              textColor: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            // Details Button with hover
                            HoverOutlinedButton( // Use the custom widget
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(job['title'] ?? ""),
                                      content: SingleChildScrollView( // Added for potentially long details
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Category: ${job['category']}"),
                                            Text(
                                                "Location: ${job['location']}"),
                                            Text("Salary: ${job['salary']}"),
                                            Text("Job Type: ${job['jobType']}"),
                                            const SizedBox(height: 8),
                                            Text(
                                                "Description: ${job['description']}"),
                                            const SizedBox(height: 8),
                                            Text(
                                                "Requirements: ${job['requirements']}"),
                                            const SizedBox(height: 8),
                                            Text("Company: ${job['company']}"),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Close"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              text: "Details",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}