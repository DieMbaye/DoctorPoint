import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createAppointment({
    required String doctorId,
    required String doctorName,
    required String consultationType,
    required int price,
    required String date,
    required String time,
    required String paymentMethod,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _db.collection('appointments').add({
      'userId': uid,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'consultationType': consultationType,
      'price': price,
      'date': date,
      'time': time,
      'paymentMethod': paymentMethod,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔔 notification automatique
    await _db.collection('notifications').add({
      'userId': uid,
      'title': 'Rendez-vous confirmé',
      'message':
          'Votre rendez-vous avec $doctorName est confirmé ($date à $time)',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
