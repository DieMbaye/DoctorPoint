import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String consultationType;
  final int price;
  final String date;
  final String time;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.consultationType,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String paymentMethod = 'wave';
  bool loading = false;

  Future<void> _confirmPayment() async {
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    /// ✅ 1. APPOINTMENT
    await firestore.collection('appointments').add({
      'userId': user.uid,
      'doctorId': widget.doctorId,
      'doctorName': widget.doctorName,
      'consultationType': widget.consultationType,
      'price': widget.price,
      'date': widget.date,
      'time': widget.time,
      'paymentMethod': paymentMethod,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    /// ✅ 2. NOTIFICATION
    await firestore.collection('notifications').add({
      'userId': user.uid,
      'title': 'Rendez-vous confirmé',
      'message':
          'Votre rendez-vous avec ${widget.doctorName} est confirmé.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          doctorName: widget.doctorName,
          consultationType: widget.consultationType,
          price: widget.price,
          date: widget.date,
          time: widget.time, paymentMethod: '', method: '', doctorId: '', doctorPhoto: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un moyen de paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _paymentOption('Wave', 'wave'),
            _paymentOption('Orange Money', 'orange'),
            _paymentOption('Free Money', 'free'),

            const Spacer(),

            ElevatedButton(
              onPressed: loading ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Payer ${widget.price} FCFA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String label, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: paymentMethod,
      onChanged: (v) => setState(() => paymentMethod = v!),
      title: Text(label),
      activeColor: AppColors.primary,
    );
  }
}
