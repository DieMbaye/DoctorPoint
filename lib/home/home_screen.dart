import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final data = snapshot.data!.data()!;
          return Center(
            child: Text(
              'Bienvenue ${data['fullName']} 👋',
              style: const TextStyle(fontSize: 22),
            ),
          );
        },
      ),
    );
  }
}
