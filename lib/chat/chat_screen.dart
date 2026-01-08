import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  const ChatScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  Future<void> _endChat() async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'title': 'Discussion terminée',
      'message':
          'Votre discussion avec ${widget.doctorName} est terminée avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content:
            const Text('Messagerie terminée avec succès.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HomeScreen(userName: 'Utilisateur'),
                ),
                (_) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.doctorPhoto),
            ),
            const SizedBox(width: 10),
            Text(widget.doctorName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _endChat,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Bonjour, comment puis-je vous aider ?'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: AppColors.primary),
                  onPressed: () => _msgCtrl.clear(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
