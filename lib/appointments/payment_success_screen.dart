import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String method;
  final String doctorId;
  final String doctorName;
  final String consultationType;
  final int price;
  final String date;
  final String time;

  const PaymentSuccessScreen({
    super.key,
    required this.method,
    required this.doctorId,
    required this.doctorName,
    required this.consultationType,
    required this.price,
    required this.date,
    required this.time,
  });

  Future<void> _saveToFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    // 1️⃣ ENREGISTRER LE RENDEZ-VOUS
    await firestore.collection('appointments').add({
      'userId': user.uid,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'consultationType': consultationType,
      'price': price,
      'date': date,
      'time': time,
      'paymentMethod': method,
      'status': 'confirmé',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ CRÉER LA NOTIFICATION
    await firestore.collection('notifications').add({
      'userId': user.uid,
      'title': 'Rendez-vous confirmé',
      'message':
          'Votre rendez-vous avec $doctorName est confirmé le $date à $time.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3️⃣ REDIRECTION PROPRE
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(userName: 'Utilisateur'),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = {
      'voice': 'Appel vocal',
      'message': 'Messagerie',
      'video': 'Appel vidéo',
    }[consultationType] ?? consultationType;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
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
                'Paiement $method réussi',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _saveToFirestore(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
