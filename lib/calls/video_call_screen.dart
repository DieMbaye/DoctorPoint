import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  const VideoCallScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
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
      'title': 'Appel vidéo terminé',
      'message':
          'Votre appel vidéo avec ${widget.doctorName} est terminé avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Appel vidéo terminé avec succès.'),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // vidéo médecin (simulée)
          Positioned.fill(
            child: Image.network(
              widget.doctorPhoto,
              fit: BoxFit.cover,
            ),
          ),

          // caméra utilisateur simulée
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person,
                  color: Colors.white, size: 50),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(time,
                    style:
                        const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child:
                      const Icon(Icons.mic_off, color: Colors.white),
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
                  child: const Icon(Icons.videocam_off,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
