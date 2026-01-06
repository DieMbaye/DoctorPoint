import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // ================= REGISTER =================
  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(result.user!.uid).set({
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'profileCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return result.user;
  }

  // ================= PROFILE CHECK =================
  Future<bool> isProfileCompleted(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['profileCompleted'] == true;
  }

  // ================= COMPLETE PROFILE =================
  Future<void> completeProfile({
    required String uid,
    required String gender,
    required DateTime birthDate,
    required String address,
    required String photoUrl,
  }) async {
    await _db.collection('users').doc(uid).update({
      'gender': gender,
      'birthDate': birthDate,
      'address': address,
      'photoUrl': photoUrl,
      'profileCompleted': true,
    });
  }
}
