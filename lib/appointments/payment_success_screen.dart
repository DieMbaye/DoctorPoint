import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../calls/voice_call_screen.dart';
import '../calls/video_call_screen.dart';
import '../chat/chat_screen.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String consultationType;
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;
  final int price;
  final String date;
  final String time;
  final String paymentMethod;
  final String method;

  const PaymentSuccessScreen({
    super.key,
    required this.consultationType,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
    required this.price,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.method,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isLoading = false;

  String get typeLabel {
    switch (widget.consultationType) {
      case 'voice':
        return 'Appel vocal';
      case 'video':
        return 'Appel vidéo';
      case 'message':
        return 'Messagerie';
      default:
        return '';
    }
  }

  IconData get typeIcon {
    switch (widget.consultationType) {
      case 'voice':
        return Icons.call_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  void _startSession() async {
    setState(() => _isLoading = true);
    
    // Simuler un petit délai
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (widget.consultationType == 'voice') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            doctorPhoto: widget.doctorPhoto,
          ),
        ),
      );
    } else if (widget.consultationType == 'video') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            doctorPhoto: widget.doctorPhoto,
          ),
        ),
      );
    } else if (widget.consultationType == 'message') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            doctorPhoto: widget.doctorPhoto,
          ),
        ),
      );
    }
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userName: 'Utilisateur'),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Success Animation/Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// Success Title
              Text(
                'Paiement réussi !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              /// Success Message
              Text(
                'Votre $typeLabel est confirmé',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${widget.price} FCFA • ${widget.method}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              /// Appointment Details Card
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
                  children: [
                    _detailRow(
                      Icons.person_rounded,
                      'Médecin',
                      widget.doctorName,
                    ),
                    const SizedBox(height: 20),
                    _detailRow(
                      Icons.calendar_month_rounded,
                      'Date',
                      widget.date,
                    ),
                    const SizedBox(height: 20),
                    _detailRow(
                      Icons.access_time_rounded,
                      'Heure',
                      widget.time,
                    ),
                    const SizedBox(height: 20),
                    _detailRow(
                      typeIcon,
                      'Consultation',
                      typeLabel,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// Start Session Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
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
                              typeIcon,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.consultationType == 'message'
                                  ? 'Ouvrir la messagerie'
                                  : 'Démarrer $typeLabel',
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

              /// Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: _goToHome,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retour à l\'accueil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}