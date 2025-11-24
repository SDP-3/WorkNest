import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminChatDetailScreen extends StatefulWidget {
  final String userId;
  final String? userEmail;
  final String? userName; // 🔹 নাম যোগ করা হলো

  const AdminChatDetailScreen({
    super.key,
    required this.userId,
    this.userEmail,
    this.userName, // 🔹 কনস্ট্রাক্টরে নাম নেওয়া হচ্ছে
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendAdminReply() async {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.userId)
        .collection('messages')
        .add({
          'text': message,
          'sender_id': 'admin',
          'timestamp': FieldValue.serverTimestamp(),
          'is_admin': true,
        });

    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.userId)
        .update({
          'last_message': "Admin: $message",
          'last_time': FieldValue.serverTimestamp(),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        titleSpacing: 0,
        // 🔹 টাইটেল ডিজাইন আপডেট করা হলো
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // বড় করে নাম
                Text(
                  widget.userName ?? "Unknown User",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // ছোট করে ইমেইল
                Text(
                  widget.userEmail ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(widget.userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index].data() as Map<String, dynamic>;
                    bool isAdmin = msg['is_admin'] == true;

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.blue[900] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12).copyWith(
                            bottomRight: isAdmin ? Radius.zero : null,
                            bottomLeft: !isAdmin ? Radius.zero : null,
                          ),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: GoogleFonts.poppins(
                            color: isAdmin ? Colors.white : Colors.black87,
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
                    decoration: const InputDecoration(
                      hintText: "Reply as Admin...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendAdminReply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
