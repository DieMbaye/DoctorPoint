import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user!;
  }

  // REGISTER
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(res.user!.uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return res.user!;
  }

  // COMPLETE PROFILE
  Future<void> completeProfile({
    required String uid,
    required String gender,
    required DateTime birthDate,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).update({
      'gender': gender,
      'birthDate': birthDate,
      'address': address,
      'profileCompleted': true,
    });
  }
}
