import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* ============================================================
   * 🔐 REGISTER PATIENT
   * ============================================================ */
  Future<User> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // Collection users (patients)
    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'address': '',
      'birthDate': null,
      'profileCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'patient',
    });

    return cred.user!;
  }

  /* ============================================================
   * 🔐 REGISTER DOCTOR
   * ============================================================ */
  Future<User> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
    required String about,
    required String specialty,
    required int experienceYears,
    required String hospital,
    required int patients,
    required Map<String, int> fees,
    required List<String> workingDays,
    String? startTime,
    String? endTime,
    List<String>? workingHours,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // 1️⃣ Collection medecin (profil complet)
    Map<String, dynamic> doctorData = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'about': about,
      'specialty': specialty,
      'experienceYears': experienceYears,
      'hospital': hospital,
      'patients': patients,
      'fees': {
        'message': fees['message'] ?? 5000,
        'video': fees['video'] ?? 15000,
        'voice': fees['voice'] ?? 10000,
      },
      'workingDays': workingDays,
      'rating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'medecin',
      'profileCompleted': true, // Les médecins ont un profil complet dès l'inscription
    };

    // Ajouter les horaires
    if (workingHours != null && workingHours.isNotEmpty) {
      doctorData['workingHours'] = workingHours;
    } else {
      doctorData['startTime'] = startTime ?? '08:00';
      doctorData['endTime'] = endTime ?? '18:00';
    }

    await _db.collection('medecin').doc(uid).set(doctorData);

    // 2️⃣ Collection users (entrée légère pour faciliter la recherche)
    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': 'medecin',
      'profileCompleted': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred.user!;
  }

  /* ============================================================
   * 🔑 LOGIN
   * ============================================================ */
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  /* ============================================================
   * 👤 COMPLETE PROFILE (SETUP) - UNIQUEMENT POUR PATIENT
   * ============================================================ */
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

  /* ============================================================
   * 🚀 HANDLE START (Splash / Onboarding)
   * ============================================================ */
  Future<String> handleStart() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 'onboarding'; // pas connecté
    }

    // Chercher d'abord dans users
    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      return 'onboarding';
    }

    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'] ?? 'patient';
    final completed = data['profileCompleted'] ?? false;

    if (role == 'medecin') {
      return 'home'; // Les médecins vont directement au home
    }

    return completed ? 'home' : 'setup';
  }

  /* ============================================================
   * 📄 GET USER PROFILE (Complet selon le rôle)
   * ============================================================ */
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    // D'abord chercher dans users pour connaître le rôle
    final userDoc = await _db.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      return {};
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final role = userData['role'] ?? 'patient';

    // Si c'est un médecin, récupérer les infos complémentaires de la collection medecin
    if (role == 'medecin') {
      final doctorDoc = await _db.collection('medecin').doc(uid).get();
      if (doctorDoc.exists) {
        return {
          ...userData,
          ...(doctorDoc.data() as Map<String, dynamic>),
        };
      }
    }

    return userData;
  }

  /* ============================================================
   * 🩺 GET DOCTOR PROFILE (Direct depuis collection medecin)
   * ============================================================ */
  Future<Map<String, dynamic>> getDoctorProfile(String uid) async {
    final doc = await _db.collection('medecin').doc(uid).get();
    return doc.data() ?? {};
  }

  /* ============================================================
   * 📋 GET USER ROLE
   * ============================================================ */
  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return 'unknown';
    return doc.data()?['role'] ?? 'patient';
  }

  /* ============================================================
   * 🚪 LOGOUT
   * ============================================================ */
  Future<void> logout() async {
    await _auth.signOut();
  }

  /* ============================================================
   * 🔍 CHECK IF DOCTOR
   * ============================================================ */
  Future<bool> isDoctor(String uid) async {
    final role = await getUserRole(uid);
    return role == 'medecin';
  }
}