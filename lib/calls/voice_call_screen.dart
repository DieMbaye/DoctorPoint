import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import 'call_ended_screen.dart';

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
  bool isMuted = false;
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
      'title': 'Appel vocal terminé',
      'message': 'Votre appel vocal avec ${widget.doctorName} est terminé avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallEndedScreen(
          doctorName: widget.doctorName,
          type: 'voice',
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
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            /// Status Bar Space
            Container(height: 20),

            /// Call Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Doctor Photo or Icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                    ),
                    child: widget.doctorPhoto.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Image.network(
                              widget.doctorPhoto,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.medical_services_rounded,
                              size: 60,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  /// Doctor Name
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Call Status
                  Text(
                    'Appel vocal en cours',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Call Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Call Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Mute Button
                  _callControlButton(
                    icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: isMuted ? 'Réactiver' : 'Couper',
                    isActive: isMuted,
                    onPressed: () => setState(() => isMuted = !isMuted),
                  ),

                  /// Speaker Button
                  _callControlButton(
                    icon: isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    label: isSpeakerOn ? 'Haut-parleur' : 'Écouteur',
                    isActive: isSpeakerOn,
                    onPressed: () => setState(() => isSpeakerOn = !isSpeakerOn),
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
                          blurRadius: 20,
                          spreadRadius: 5,
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

                  /// Keypad Button
                  _callControlButton(
                    icon: Icons.dialpad_rounded,
                    label: 'Clavier',
                    isActive: false,
                    onPressed: () {
                      // TODO: Show keypad
                    },
                  ),

                  /// Add Call Button
                  _callControlButton(
                    icon: Icons.add_card_rounded,
                    label: 'Ajouter',
                    isActive: false,
                    onPressed: () {
                      // TODO: Add call functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}