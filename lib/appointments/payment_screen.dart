import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String consultationType;
  final int price;
  final String date;
  final String time;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.consultationType,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String paymentMethod = 'wave';
  bool loading = false;

  Map<String, Map<String, dynamic>> paymentMethods = {
    'wave': {
      'name': 'Wave',
      'icon': 'assets/images/wave.png',
      'color': Color(0xFF00B2FF),
      'description': 'Paiement rapide et sécurisé',
    },
    'orange': {
      'name': 'Orange Money',
      'icon': 'assets/images/orange_money.png',
      'color': Color(0xFFFF6B00),
      'description': 'Paiement mobile Orange',
    },
    'free': {
      'name': 'Free Money',
      'icon': 'assets/images/free_money.png',
      'color': Color(0xFF8E44AD),
      'description': 'Paiement mobile Free',
    },
  };

  String get consultationTypeLabel {
    switch (widget.consultationType) {
      case 'voice':
        return 'Appel vocal';
      case 'video':
        return 'Appel vidéo';
      case 'message':
        return 'Messagerie';
      default:
        return widget.consultationType;
    }
  }

  Future<void> _confirmPayment() async {
    if (!mounted) return;
    
    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final firestore = FirebaseFirestore.instance;

      /// 1. Créer le rendez-vous
      final appointmentRef = await firestore.collection('appointments').add({
        'userId': user.uid,
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'consultationType': widget.consultationType,
        'price': widget.price,
        'date': widget.date,
        'time': widget.time,
        'paymentMethod': paymentMethod,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// 2. Créer la notification
      await firestore.collection('notifications').add({
        'userId': user.uid,
        'title': 'Rendez-vous confirmé ✅',
        'message': 'Votre rendez-vous avec ${widget.doctorName} est confirmé pour le ${widget.date} à ${widget.time}.',
        'read': false,
        'appointmentId': appointmentRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      // Simuler un petit délai pour l'animation
      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            doctorPhoto: '', // Vous devriez passer la photo si disponible
            consultationType: widget.consultationType,
            price: widget.price,
            date: widget.date,
            time: widget.time,
            paymentMethod: paymentMethod,
            method: paymentMethods[paymentMethod]!['name'] as String,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => loading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de paiement: ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Paiement sécurisé',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Appointment Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Résumé du paiement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              consultationTypeLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _detailRow('Médecin', widget.doctorName),
                  _detailRow('Date', widget.date),
                  _detailRow('Heure', widget.time),
                  const SizedBox(height: 20),
                  Divider(
                    color: AppColors.border,
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total à payer',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.price} FCFA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// Payment Methods Title
            Text(
              'Choisissez votre moyen de paiement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez une option de paiement sécurisée',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            /// Payment Methods List
            ...paymentMethods.entries.map((entry) {
              final methodKey = entry.key;
              final methodData = entry.value;
              final isSelected = paymentMethod == methodKey;

              return GestureDetector(
                onTap: () {
                  setState(() => paymentMethod = methodKey);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? methodData['color'] as Color
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? methodData['color'] as Color
                          : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image du logo
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : (methodData['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Image.asset(
                          methodData['icon'] as String,
                          fit: BoxFit.contain,
                          width: 36,
                          height: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              methodData['name'] as String,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              methodData['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white 
                                : AppColors.textSecondary,
                            width: 2,
                          ),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: methodData['color'] as Color,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 32),

            /// Security Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFC8E6C9),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF388E3C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paiement 100% sécurisé. Vos données bancaires sont cryptées.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF388E3C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Pay Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: loading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payments_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Payer ${widget.price} FCFA',
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

            /// Cancel Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}