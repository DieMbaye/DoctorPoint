import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class CallEndedScreen extends StatelessWidget {
  final String doctorName;
  final String type;

  const CallEndedScreen({
    super.key,
    required this.doctorName,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                '$type terminé avec succès',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Consultation avec $doctorName',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
