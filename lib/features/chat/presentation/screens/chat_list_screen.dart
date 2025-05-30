import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گفتگوها'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_rounded, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'صفحه لیست گفتگوها (چت)',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'این صفحه در آینده تکمیل خواهد شد.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement start new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شروع گفتگوی جدید (به زودی)')),
          );
        },
        child: const Icon(Icons.add_comment_rounded),
        tooltip: 'گفتگوی جدید',
      ),
    );
  }
}