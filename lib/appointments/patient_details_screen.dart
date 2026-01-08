import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'payment_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String consultationType;
  final int price;
  final String date;
  final String time;

  const PatientDetailsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.consultationType,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  String gender = 'Homme';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Informations patient'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧾 RÉCAP RDV
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.person, 'Médecin', widget.doctorName),
                  _infoRow(Icons.calendar_today, 'Date', widget.date),
                  _infoRow(Icons.schedule, 'Heure', widget.time),
                  _infoRow(Icons.medical_services, 'Consultation',
                      widget.consultationType),
                  const Divider(height: 24),
                  _infoRow(Icons.payments, 'Prix',
                      '${widget.price} FCFA',
                      bold: true),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 👤 INFOS PATIENT
            const Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: nameCtrl,
              label: 'Nom complet',
              icon: Icons.badge,
            ),

            const SizedBox(height: 16),

            _inputField(
              controller: ageCtrl,
              label: 'Âge',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            /// ⚧ GENRE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: gender,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                    DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                  ],
                  onChanged: (v) => setState(() => gender = v!),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 💳 BOUTON PAIEMENT
            ElevatedButton(
              onPressed: nameCtrl.text.isEmpty || ageCtrl.text.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Passer au paiement'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 LIGNE INFO
  Widget _infoRow(IconData icon, String label, String value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: const TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 CHAMP TEXTE
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
