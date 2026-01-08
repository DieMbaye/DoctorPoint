import 'package:doctor_point/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Spacing
                  SizedBox(height: isTablet ? 40 : 20),
                  
                  // Header Section
                  _buildHeaderSection(),
                  
                  // Main Content
                  _buildMainContent(context, size),
                  
                  // Bottom Spacing
                  SizedBox(height: isTablet ? 60 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Welcome Message
        Text(
          'Bienvenue sur',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // App Name
        Text(
          'DOCTORPOINT',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'Votre plateforme de rendez-vous médicaux',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: size.width > 500 ? 60 : 0,
      ),
      child: Column(
        children: [
          // Illustration/Logo Area
          _buildIllustrationArea(size),
          
          const SizedBox(height: 40),
          
          // Description
          _buildDescription(),
          
          const SizedBox(height: 40),
          
          // Action Buttons
          _buildActionButtons(context),
          
          const SizedBox(height: 32),
          
          // Divider
          _buildDivider(),
          
          const SizedBox(height: 32),
          
          // Secondary Options
          _buildSecondaryOptions(context),
        ],
      ),
    );
  }

  Widget _buildIllustrationArea(Size size) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6,
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Decorative Elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          
          // Main Logo/Image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Name Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'DOCTORPOINT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            'Gérez vos rendez-vous médicaux en toute simplicité.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Rejoignez notre communauté de patients et '
            'professionnels de santé pour une expérience médicale optimisée.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Register Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateTo(context, const RegisterScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Créer un compte gratuitement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Login Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _navigateTo(context, const LoginScreen()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Accès rapide',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryOptions(BuildContext context) {
    return Column(
      children: [
        // Guest Access
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mode invité activé - Fonctionnalités limitées',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Continuer sans compte',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Terms
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'En continuant, vous acceptez nos '),
                TextSpan(
                  text: 'Conditions d\'utilisation',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' et notre '),
                TextSpan(
                  text: 'Politique de confidentialité',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}