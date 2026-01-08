import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../appointments/patient_details_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime? selectedDate;
  String? selectedHour;
  String selectedType = 'voice';
  int selectedPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('Médecin introuvable'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String fullName = data['fullName'] ?? '';
          final String specialty = data['specialty'] ?? '';
          final String hospital = data['hospital'] ?? '';
          final String about = data['about'] ?? '';
          final String? photoUrl = data['photoUrls'];

          final List<String> workingDays =
              List<String>.from(data['workingDays'] ?? []);

          final List<String> workingHours =
              List<String>.from(data['workingHours'] ?? []);

          final Map<String, dynamic> fees =
              Map<String, dynamic>.from(data['fees'] ?? {});

          final int voiceFee = fees['voice'] ?? 0;
          final int messageFee = fees['message'] ?? 0;
          final int videoFee = fees['video'] ?? 0;

          // prix dynamique
          if (selectedType == 'voice') selectedPrice = voiceFee;
          if (selectedType == 'message') selectedPrice = messageFee;
          if (selectedType == 'video') selectedPrice = videoFee;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : Container(color: AppColors.primary),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('$specialty • $hospital',
                          style: const TextStyle(color: Colors.grey)),

                      const SizedBox(height: 20),
                      const Text('À propos',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(about),

                      const SizedBox(height: 24),
                      const Text('Choisir une date',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _buildDates(workingDays),

                      const SizedBox(height: 24),
                      const Text('Choisir une heure',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _buildHours(workingHours),

                      const SizedBox(height: 24),
                      const Text('Type de consultation',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),

                      _typeCard(
                          icon: Icons.phone,
                          label: 'Appel',
                          price: voiceFee,
                          value: 'voice'),
                      _typeCard(
                          icon: Icons.message,
                          label: 'Message',
                          price: messageFee,
                          value: 'message'),
                      _typeCard(
                          icon: Icons.videocam,
                          label: 'Vidéo',
                          price: videoFee,
                          value: 'video'),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: selectedDate != null &&
                                selectedHour != null &&
                                selectedPrice > 0
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PatientDetailsScreen(
                                      doctorId: widget.doctorId,
                                      doctorName: fullName,
                                      consultationType: selectedType,
                                      price: selectedPrice,
                                      date: DateFormat('dd/MM/yyyy')
                                          .format(selectedDate!),
                                      time: selectedHour!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                            'Prendre rendez-vous • $selectedPrice FCFA'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ================== DATES ==================
  Widget _buildDates(List<String> workingDays) {
    if (workingDays.isEmpty) {
      return const Text('Aucune date disponible',
          style: TextStyle(color: Colors.grey));
    }

    final normalizedDays = workingDays
        .map((d) => d.toLowerCase().replaceAll('.', '').trim())
        .toList();

    final now = DateTime.now();

    final dates = List.generate(21, (i) => now.add(Duration(days: i)))
        .where((date) {
          final day =
              DateFormat('EEE', 'fr_FR').format(date).toLowerCase();
          return normalizedDays
              .contains(day.replaceAll('.', '').trim());
        })
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((date) {
          final isSelected = selectedDate != null &&
              DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(selectedDate!);

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                children: [
                  Text(DateFormat('EEE', 'fr_FR').format(date),
                      style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text(DateFormat('d MMM yyyy', 'fr_FR').format(date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ================== HEURES ==================
  Widget _buildHours(List<String> hours) {
    if (hours.isEmpty) {
      return const Text('Aucune heure disponible',
          style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hours.map((h) {
        final isSelected = selectedHour == h;
        return GestureDetector(
          onTap: () => setState(() => selectedHour = h),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(h,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black)),
          ),
        );
      }).toList(),
    );
  }

  /// ================== TYPE ==================
  Widget _typeCard(
      {required IconData icon,
      required String label,
      required int price,
      required String value}) {
    final selected = selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => selectedType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color:
                          selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600)),
            ),
            Text('$price FCFA',
                style: TextStyle(
                    color:
                        selected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
