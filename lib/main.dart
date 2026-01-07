import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';

// SCREENS
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'profile/setup_profile_screen.dart';
import 'home/home_screen.dart';

// SERVICES
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DoctorPointApp());
}

class DoctorPointApp extends StatelessWidget {
  const DoctorPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌍 LOCALISATION (IMPORTANT POUR DatePicker)
      locale: const Locale('fr'),
      supportedLocales: const [
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🎨 THEME GLOBAL (VERT / BLANC)
      theme: ThemeData(
        primaryColor: const Color(0xFF16A085),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16A085),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A085),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 🚀 POINT D’ENTRÉE UNIQUE
      home: const Root(),
    );
  }
}

///
/// 🎯 ROOT
/// Décide automatiquement où envoyer l’utilisateur
///
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService().handleStart(),
      builder: (context, snapshot) {
        // ⏳ Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ❌ Erreur ou aucune donnée
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 🔀 Navigation contrôlée
        switch (snapshot.data) {
          case 'onboarding':
            return const OnboardingScreen();

          case 'login':
            return const LoginScreen();

          case 'setup':
            return const SetupProfileScreen(uid: '');

          case 'home':
            return const HomeScreen(userName: '');

          default:
            return const LoginScreen();
        }
      },
    );
  }
}
