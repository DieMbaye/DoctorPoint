import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import 'call_ended_screen.dart';

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
  bool isMuted = false;
  bool isVideoOff = false;
  bool isSpeakerOn = true;

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
      'message': 'Votre appel vidéo avec ${widget.doctorName} est terminé avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallEndedScreen(
          doctorName: widget.doctorName,
          type: 'video',
        ),
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
          /// Doctor's Video (Simulated)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: widget.doctorPhoto.isNotEmpty
                  ? Image.network(
                      widget.doctorPhoto,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_services_rounded,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.doctorName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          /// User's Camera Preview
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Header Info
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appel vidéo • $time',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Call Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Mute Button
                  _callControlButton(
                    icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: isMuted ? 'Son coupé' : 'Couper le son',
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () => setState(() => isMuted = !isMuted),
                  ),

                  /// Video Toggle
                  _callControlButton(
                    icon: isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    label: isVideoOff ? 'Caméra éteinte' : 'Éteindre la caméra',
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () => setState(() => isVideoOff = !isVideoOff),
                  ),

                  /// End Call Button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _endCall,
                    ),
                  ),

                  /// Speaker Button
                  _callControlButton(
                    icon: isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    label: isSpeakerOn ? 'Haut-parleur activé' : 'Activer haut-parleur',
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () => setState(() => isSpeakerOn = !isSpeakerOn),
                  ),

                  /// More Options
                  _callControlButton(
                    icon: Icons.more_vert_rounded,
                    label: 'Plus d\'options',
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () {
                      // TODO: Show more options menu
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}