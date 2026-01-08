import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class VoiceCallScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  const VoiceCallScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late Timer _timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  String get time =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  Future<void> _endCall() async {
    _timer.cancel();

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'title': 'Appel vocal terminé',
      'message':
          'Votre appel vocal avec ${widget.doctorName} est terminé avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Appel vocal terminé avec succès.'),
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.doctorName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(time,
                style: const TextStyle(color: Colors.white70)),

            const SizedBox(height: 40),

            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(widget.doctorPhoto),
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.mic_off, color: Colors.white),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end,
                        color: Colors.white),
                    onPressed: _endCall,
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.volume_up,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
