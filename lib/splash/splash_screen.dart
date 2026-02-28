import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../profile/setup_profile_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(seconds: 2));

    final result = await authService.handleStart();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    switch (result) {
      case 'onboarding':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
        break;

      case 'setup':
        // Récupérer le rôle de l'utilisateur
        if (user != null) {
          final role = await authService.getUserRole(user.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SetupProfileScreen(
                uid: user.uid,
                role: role, // 👈 Ajout du rôle requis
              ),
            ),
          );
        } else {
          // Si pas d'utilisateur, rediriger vers login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        break;

      // Dans splash_screen.dart, assurez-vous de passer le rôle

case 'home':
  if (user != null) {
    final profile = await authService.getUserProfile(user.uid);
    final userName = profile['fullName'] ?? '';
    final role = profile['role'] ?? 'patient';
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userName: userName,
          role: role, // 👈 Passage du rôle
        ),
      ),
    );
  }
  break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ FOND BLANC
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🖼️ LOGO OFFICIEL
            Image.asset(
              'assets/images/logo.png',
              width: 160,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}