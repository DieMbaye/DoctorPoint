import 'package:flutter/material.dart';
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
  String method = 'wave';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _option('Wave', 'assets/images/wave.png', 'wave'),
            _option('Orange Money', 'assets/images/orange_money.png', 'orange'),
            _option('Free Money', 'assets/images/free_money.png', 'free'),

            const Spacer(),

            ElevatedButton(
              onPressed: _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirmer le paiement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(String label, String asset, String value) {
    return ListTile(
      leading: Image.asset(asset, width: 40),
      title: Text(label),
      trailing: Radio<String>(
        value: value,
        groupValue: method,
        activeColor: AppColors.primary,
        onChanged: (v) => setState(() => method = v!),
      ),
    );
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Confirmer le paiement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessScreen(
                    method: method,
                    doctorId: widget.doctorId,
                    doctorName: widget.doctorName,
                    consultationType: widget.consultationType,
                    price: widget.price,
                    date: widget.date,
                    time: widget.time,
                  ),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
