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
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100) {
      if (!_showAppBarTitle) setState(() => _showAppBarTitle = true);
    } else {
      if (_showAppBarTitle) setState(() => _showAppBarTitle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medecin')
            .doc(widget.doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Médecin introuvable'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String fullName = data['fullName'] ?? 'Dr. Inconnu';
          final String specialty = data['specialty'] ?? 'Médecin généraliste';
          final String hospital = data['hospital'] ?? 'Hôpital non spécifié';
          final String about = data['about'] ?? '';
          final String? photoUrl = data['photoUrls'];
          final int experienceYears = data['experienceYears'] ?? 0;
          final double rating = (data['rating'] as num?)?.toDouble() ?? 4.0;

          final List<String> workingDays =
              List<String>.from(data['workingDays'] ?? []);
          final List<String> workingHours =
              List<String>.from(data['workingHours'] ?? []);

          final Map<String, dynamic> fees =
              Map<String, dynamic>.from(data['fees'] ?? {});

          final int voiceFee = fees['voice'] ?? 5000;
          final int messageFee = fees['message'] ?? 3000;
          final int videoFee = fees['video'] ?? 10000;

          // Mettre à jour le prix sans setState pour éviter le rebuild complet
          int currentPrice = selectedPrice;
          if (selectedType == 'voice') currentPrice = voiceFee;
          if (selectedType == 'message') currentPrice = messageFee;
          if (selectedType == 'video') currentPrice = videoFee;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              /// App Bar
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                floating: false,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 12),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                    iconSize: 22,
                  ),
                ),
                title: _showAppBarTitle
                    ? Text(
                        fullName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary,
                              child: Center(
                                child: Text(
                                  fullName.isNotEmpty ? fullName[0] : 'D',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              fullName.isNotEmpty ? fullName[0] : 'D',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              /// Doctor Info Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$specialty • $hospital',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFB800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB800),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$experienceYears ans',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// About Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À propos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        about.isNotEmpty
                            ? about
                            : 'Docteur spécialisé avec $experienceYears années d\'expérience dans le domaine médical. Disponible pour des consultations en ligne.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Appointment Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
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
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Choose Date
                          Text(
                            'Choisir une date',
                            key: const ValueKey('date_section'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDates(workingDays, setState),
                          
                          const SizedBox(height: 30),
                          
                          /// Choose Time
                          Text(
                            'Choisir une heure',
                            key: const ValueKey('time_section'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildHours(workingHours, setState),
                          
                          const SizedBox(height: 30),
                          
                          /// Consultation Type
                          Text(
                            'Type de consultation',
                            key: const ValueKey('type_section'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTypeSelector(voiceFee, messageFee, videoFee, setState),
                          
                          const SizedBox(height: 32),
                          
                          /// Book Appointment Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: selectedDate != null &&
                                      selectedHour != null &&
                                      currentPrice > 0
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PatientDetailsScreen(
                                            doctorId: widget.doctorId,
                                            doctorName: fullName,
                                            consultationType: selectedType,
                                            price: currentPrice,
                                            date: DateFormat('dd/MM/yyyy')
                                                .format(selectedDate!),
                                            time: selectedHour!,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedDate != null &&
                                        selectedHour != null &&
                                        currentPrice > 0
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.3),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Prendre rendez-vous',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$currentPrice FCFA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              /// Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Dates
  Widget _buildDates(List<String> workingDays, Function setState) {
    if (workingDays.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Aucune date disponible cette semaine',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final normalizedDays = workingDays
        .map((d) => d.toLowerCase().replaceAll('.', '').trim())
        .toList();

    final now = DateTime.now();
    final dates = List.generate(21, (i) => now.add(Duration(days: i)))
        .where((date) {
          final day = DateFormat('EEE', 'fr_FR').format(date).toLowerCase();
          return normalizedDays.contains(day.replaceAll('.', '').trim());
        })
        .toList();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selectedDate != null &&
              DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(selectedDate!);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'fr_FR').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d', 'fr_FR').format(date),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM yyyy', 'fr_FR').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Heures
  Widget _buildHours(List<String> hours, Function setState) {
    if (hours.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Aucune heure disponible',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: hours.map((h) {
        final isSelected = selectedHour == h;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedHour = h;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              h,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Type selector
  Widget _buildTypeSelector(int voiceFee, int messageFee, int videoFee, Function setState) {
    return Column(
      children: [
        _buildTypeCard(
          icon: Icons.phone_rounded,
          label: 'Appel vocal',
          price: voiceFee,
          value: 'voice',
          setState: setState,
        ),
        const SizedBox(height: 12),
        _buildTypeCard(
          icon: Icons.chat_bubble_rounded,
          label: 'Messagerie',
          price: messageFee,
          value: 'message',
          setState: setState,
        ),
        const SizedBox(height: 12),
        _buildTypeCard(
          icon: Icons.videocam_rounded,
          label: 'Appel vidéo',
          price: videoFee,
          value: 'video',
          setState: setState,
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String label,
    required int price,
    required String value,
    required Function setState,
  }) {
    final selected = selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$price FCFA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}