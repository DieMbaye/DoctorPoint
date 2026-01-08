import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/language_service.dart';
import 'splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const DoctorPointApp(),
    ),
  );
}

class DoctorPointApp extends StatelessWidget {
  const DoctorPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🌍 LANGUE DYNAMIQUE
      locale: languageService.locale,

      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primaryColor: const Color(0xFF16A085),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16A085),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
