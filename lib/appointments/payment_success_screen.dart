import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../calls/voice_call_screen.dart';
import '../calls/video_call_screen.dart';
import '../chat/chat_screen.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String consultationType; // voice | video | message
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;
  final int price;
  final String date;
  final String time;

  const PaymentSuccessScreen({
    super.key,
    required this.consultationType,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
    required this.price,
    required this.date,
    required this.time, required String paymentMethod, required String method,
  });

  String get typeLabel {
    switch (consultationType) {
      case 'voice':
        return 'Appel vocal';
      case 'video':
        return 'Appel vidéo';
      case 'message':
        return 'Messagerie';
      default:
        return '';
    }
  }

  void _startSession(BuildContext context) {
    if (consultationType == 'voice') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            doctorId: doctorId,
            doctorName: doctorName,
            doctorPhoto: doctorPhoto,
          ),
        ),
      );
    }

    if (consultationType == 'video') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            doctorId: doctorId,
            doctorName: doctorName,
            doctorPhoto: doctorPhoto,
          ),
        ),
      );
    }

    if (consultationType == 'message') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            doctorId: doctorId,
            doctorName: doctorName,
            doctorPhoto: doctorPhoto,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: 90, color: AppColors.primary),
              const SizedBox(height: 20),

              Text(
                '$typeLabel confirmé',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Paiement réussi • $price FCFA',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _infoRow('Médecin', doctorName),
                    _infoRow('Date', date),
                    _infoRow('Heure', time),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => _startSession(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  consultationType == 'message'
                      ? 'Ouvrir la messagerie'
                      : 'Démarrer $typeLabel',
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
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
                child: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
