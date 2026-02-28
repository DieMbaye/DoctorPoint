import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../services/notification_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final int initialFilter;
  
  const DoctorAppointmentsScreen({super.key, this.initialFilter = 0});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  late int _selectedFilter;
  
  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  // Fonction pour parser la date depuis le format "dd/MM/yyyy"
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('❌ Erreur parsing date: $e');
    }
    return null;
  }

  // Fonction pour comparer les dates (ignorer l'heure)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des rendez-vous'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _refreshAppointments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildAppointmentsList(),
          ),
        ],
      ),
    );
  }

  void _refreshAppointments() {
    setState(() {});
  }

  Widget _buildFilterTabs() {
    final filters = ['Tous', 'Aujourd\'hui', 'À venir', 'Passés'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filters[index]),
                selected: _selectedFilter == index,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary.withOpacity(0.1),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedFilter == index 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
                  fontWeight: _selectedFilter == index 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selectedFilter == index 
                        ? AppColors.primary 
                        : AppColors.border,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Utilisateur non connecté',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    try {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            print('❌ Erreur StreamBuilder: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshAppointments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun rendez-vous',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyMessage(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Filtrer les rendez-vous selon l'onglet sélectionné
          final allAppointments = snapshot.data!.docs;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final filteredAppointments = allAppointments.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final dateStr = data['date'] as String?;
            final appointmentDate = _parseDate(dateStr);
            
            if (appointmentDate == null) return _selectedFilter == 0;
            
            switch (_selectedFilter) {
              case 1: // Aujourd'hui
                return _isSameDay(appointmentDate, today);
              case 2: // À venir
                return appointmentDate.isAfter(today);
              case 3: // Passés
                return appointmentDate.isBefore(today);
              default: // Tous
                return true;
            }
          }).toList();

          if (filteredAppointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun rendez-vous pour cette période',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              final appointment = filteredAppointments[index];
              final data = appointment.data() as Map<String, dynamic>;
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['userId']) // CORRECTION: 'userId' au lieu de 'patientId'
                    .get(),
                builder: (context, patientSnapshot) {
                  String patientName = 'Patient';
                  String patientPhone = '';
                  
                  if (patientSnapshot.hasData && patientSnapshot.data!.exists) {
                    final patientData = patientSnapshot.data!.data() as Map<String, dynamic>;
                    patientName = patientData['fullName'] ?? 'Patient';
                    patientPhone = patientData['phone'] ?? '';
                  }

                  final dateStr = data['date'] as String?;
                  final appointmentDate = _parseDate(dateStr);
                  final time = data['time'] as String? ?? '--:--';
                  final status = data['status'] as String? ?? 'pending';
                  final type = data['consultationType'] as String? ?? 'message';
                  
                  // Traduire le statut
                  String statusFr = 'en_attente';
                  if (status == 'confirmed') statusFr = 'confirmé';
                  else if (status == 'cancelled') statusFr = 'refusé';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ExpansionTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getStatusColor(statusFr).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(statusFr),
                          color: _getStatusColor(statusFr),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        patientName, // Maintenant le vrai nom du patient
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointmentDate != null 
                                ? '${DateFormat('dd/MM/yyyy').format(appointmentDate)} à $time'
                                : 'Date non définie',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(statusFr).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(statusFr),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(statusFr),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                type == 'video' 
                                    ? Icons.videocam_rounded
                                    : type == 'voice'
                                        ? Icons.phone_rounded
                                        : Icons.chat_rounded,
                                size: 14,
                                color: type == 'video' 
                                    ? Colors.blue 
                                    : type == 'voice'
                                        ? Colors.green
                                        : Colors.purple,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                type == 'video' ? 'Vidéo' : type == 'voice' ? 'Audio' : 'Message',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.person_rounded,
                                'Patient',
                                patientName, // Nom du patient
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                Icons.phone_rounded,
                                'Téléphone',
                                patientPhone.isEmpty ? 'Non renseigné' : patientPhone,
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                Icons.access_time_rounded,
                                'Date et heure',
                                appointmentDate != null 
                                    ? '${DateFormat('dd/MM/yyyy').format(appointmentDate)} à $time'
                                    : 'Non définie',
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                Icons.video_call_rounded,
                                'Type de consultation',
                                type == 'video' ? 'Vidéo' : type == 'voice' ? 'Audio' : 'Message',
                              ),
                              if (data['price'] != null && data['price'] > 0) ...[
                                const Divider(height: 16),
                                _buildInfoRow(
                                  Icons.payments_rounded,
                                  'Prix',
                                  '${data['price']} FCFA',
                                ),
                              ],
                              if (data['reason'] != null && data['reason'].toString().isNotEmpty) ...[
                                const Divider(height: 16),
                                _buildInfoRow(
                                  Icons.note_rounded,
                                  'Motif',
                                  data['reason'],
                                ),
                              ],
                              const SizedBox(height: 20),
                              
                              if (statusFr == 'en_attente')
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateAppointmentStatus(
                                          appointment.id,
                                          'refusé',
                                          patientName,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: const Text('Refuser'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateAppointmentStatus(
                                          appointment.id,
                                          'confirmé',
                                          patientName,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: const Text('Confirmer'),
                                      ),
                                    ),
                                  ],
                                ),
                                
                              if (statusFr == 'confirmé')
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text(
                                          'Rendez-vous confirmé',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              if (statusFr == 'refusé')
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cancel_rounded, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text(
                                          'Rendez-vous refusé',
                                          style: TextStyle(
                                            color: Colors.red,
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
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      print('❌ Erreur dans _buildAppointmentsList: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Erreur: $e',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId, 
    String status,
    String patientName,
  ) async {
    try {
      // Traduire le statut pour Firestore
      String firestoreStatus = status == 'confirmé' ? 'confirmed' : 'cancelled';
      
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': firestoreStatus});

      // Récupérer les détails du rendez-vous pour la notification
      final appointmentDoc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      
      final data = appointmentDoc.data() as Map<String, dynamic>;
      
      // Créer une notification pour le patient
      await NotificationService.createNotification(
        userId: data['userId'], // CORRECTION: 'userId' au lieu de 'patientId'
        title: 'Rendez-vous ${status == 'confirmé' ? 'confirmé' : 'refusé'}',
        message: status == 'confirmé'
            ? 'Votre rendez-vous a été confirmé'
            : 'Votre rendez-vous a été refusé',
      );

      if (!mounted) return;
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rendez-vous ${status == 'confirmé' ? 'confirmé' : 'refusé'} avec succès',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: status == 'confirmé' ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 1:
        return 'Vous n\'avez aucun rendez-vous pour aujourd\'hui';
      case 2:
        return 'Vous n\'avez aucun rendez-vous à venir';
      case 3:
        return 'Vous n\'avez aucun rendez-vous passé';
      default:
        return 'Vous n\'avez aucun rendez-vous pour le moment';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmé':
        return Colors.green;
      case 'refusé':
        return Colors.red;
      case 'en_attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmé':
        return Icons.check_circle_rounded;
      case 'refusé':
        return Icons.cancel_rounded;
      case 'en_attente':
        return Icons.access_time_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmé':
        return 'Confirmé';
      case 'refusé':
        return 'Refusé';
      case 'en_attente':
        return 'En attente';
      default:
        return status;
    }
  }
}