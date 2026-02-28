import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:doctor_point/settings/settings_screen.dart';
import '../core/constants/app_colors.dart';
import '../doctors/doctor_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../appointments/appointments_screen.dart';
import '../appointments/doctor_appointments_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String role; // 'patient' ou 'medecin'
  
  const HomeScreen({
    super.key, 
    required this.userName,
    required this.role,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchResults = false;
  
  // Variables pour les données utilisateur
  String _userName = '';
  String? _userPhotoUrl;
  String? _userInitial;
  
  // Stats pour le médecin
  int _todayAppointments = 0;
  int _totalPatients = 0;
  int _pendingAppointments = 0;
  int _totalAppointments = 0;
  double _averageRating = 0.0;

  final List<String> weekDays = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _loadUserData();
    if (widget.role == 'medecin') {
      _loadDoctorStats();
      _listenToAppointments();
    }
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

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (widget.role == 'medecin') {
          final doctorDoc = await FirebaseFirestore.instance
              .collection('medecin')
              .doc(user.uid)
              .get();
              
          if (doctorDoc.exists) {
            final data = doctorDoc.data() as Map<String, dynamic>;
            setState(() {
              _userName = data['fullName'] ?? widget.userName;
              _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
              _userPhotoUrl = data['photoUrls'];
            });
          }
        } else {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            setState(() {
              _userName = data['fullName'] ?? widget.userName;
              _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
              _userPhotoUrl = data['photoUrl'];
            });
          } else {
            setState(() {
              _userName = widget.userName.isNotEmpty ? widget.userName : 'Utilisateur';
              _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
            });
          }
        }
      }
    } catch (e) {
      print('Erreur de chargement: $e');
      setState(() {
        _userName = widget.userName.isNotEmpty ? widget.userName : 'Utilisateur';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
      });
    }
  }

  Future<void> _loadDoctorStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      print('📊 Chargement des stats pour le médecin: ${user.uid}');
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Récupérer tous les rendez-vous
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .get();

      print('📊 Nombre total de RDV trouvés: ${appointmentsSnapshot.docs.length}');

      final allAppointments = appointmentsSnapshot.docs;

      int todayApps = 0;
      int pendingApps = 0;
      Set<String> uniquePatients = {};

      for (var doc in allAppointments) {
        final data = doc.data();
        
        // Gérer la date (string au format "dd/MM/yyyy")
        final dateStr = data['date'] as String?;
        final appointmentDate = _parseDate(dateStr);
        
        if (appointmentDate != null) {
          // Compter les RDV d'aujourd'hui
          if (_isSameDay(appointmentDate, today)) {
            todayApps++;
          }
        }
        
        // Vérifier le statut (dans votre base c'est "confirmed", "pending", etc.)
        final status = data['status'] as String? ?? 'pending';
        if (status == 'pending' || status == 'en_attente') {
          pendingApps++;
        }
        
        // Compter les patients uniques (userId dans votre base)
        final patientId = data['userId'] as String?;
        if (patientId != null) {
          uniquePatients.add(patientId);
        }
      }

      // Récupérer les stats du médecin
      final doctorDoc = await FirebaseFirestore.instance
          .collection('medecin')
          .doc(user.uid)
          .get();

      setState(() {
        _todayAppointments = todayApps;
        _pendingAppointments = pendingApps;
        _totalAppointments = allAppointments.length;
        _totalPatients = uniquePatients.length;
        
        if (doctorDoc.exists) {
          final data = doctorDoc.data() as Map<String, dynamic>;
          _averageRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        }
      });
      
      print('📊 Stats mises à jour:');
      print('   - Aujourd\'hui: $_todayAppointments');
      print('   - En attente: $_pendingAppointments');
      print('   - Total: $_totalAppointments');
      print('   - Patients uniques: $_totalPatients');
      
    } catch (e) {
      print('❌ Erreur chargement stats médecin: $e');
    }
  }

  void _listenToAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int todayApps = 0;
      int pendingApps = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        final dateStr = data['date'] as String?;
        final appointmentDate = _parseDate(dateStr);
        
        if (appointmentDate != null && _isSameDay(appointmentDate, today)) {
          todayApps++;
        }
        
        if (status == 'pending' || status == 'en_attente') {
          pendingApps++;
        }
      }
      
      setState(() {
        _todayAppointments = todayApps;
        _pendingAppointments = pendingApps;
        _totalAppointments = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER SECTION
            _buildHeader(),
            
            const SizedBox(height: 20),
            
            /// MAIN CONTENT
            Expanded(
              child: widget.role == 'patient' 
                  ? _buildPatientContent()
                  : _buildDoctorContent(),
            ),
          ],
        ),
      ),
      
      /// BOTTOM NAVIGATION
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              /// User Avatar
              _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                  ? Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(_userPhotoUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _userInitial ?? 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
              
              const SizedBox(width: 16),
              
              /// Welcome Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role == 'medecin' 
                          ? 'Bonjour Dr. ${_getFirstName()} 👨‍⚕️' 
                          : 'Bonjour, ${_getFirstName()} 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role == 'medecin'
                          ? 'Gérez vos consultations'
                          : 'Trouvez le meilleur\nsoin médical',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              /// Notification Bell
              _buildNotificationBell(),
            ],
          ),
          
          /// Search Bar (uniquement pour les patients)
          if (widget.role == 'patient') ...[
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    final user = FirebaseAuth.instance.currentUser;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user?.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _showSearchResults = value.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher un médecin, une spécialité...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _showSearchResults = false;
                    });
                    _searchController.clear();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPatientContent() {
    if (_showSearchResults && _searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services médicaux',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMedicalServices(), // Version corrigée
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Médecins populaires',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildPopularDoctors(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDoctorContent() {
    return RefreshIndicator(
      onRefresh: _loadDoctorStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Aujourd\'hui',
                  '$_todayAppointments',
                  Icons.today_rounded,
                  Colors.blue,
                ),
                _buildStatCard(
                  'En attente',
                  '$_pendingAppointments',
                  Icons.pending_actions_rounded,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total RDV',
                  '$_totalAppointments',
                  Icons.calendar_month_rounded,
                  Colors.green,
                ),
                _buildStatCard(
                  'Patients',
                  '$_totalPatients',
                  Icons.people_rounded,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            /// Demandes de rendez-vous en attente
            if (_pendingAppointments > 0) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorAppointmentsScreen(initialFilter: 0),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_pendingAppointments demande${_pendingAppointments > 1 ? 's' : ''} en attente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cliquez pour gérer vos rendez-vous',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.orange.shade900,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            /// Prochains rendez-vous
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prochains rendez-vous',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorAppointmentsScreen(initialFilter: 1),
                      ),
                    );
                  },
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            /// Liste des prochains RDV
            _buildUpcomingAppointments(),
            
            const SizedBox(height: 24),
            
            /// Horaires de travail
            _buildWorkingHoursCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun rendez-vous prévu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les nouveaux rendez-vous apparaîtront ici',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        // Filtrer les rendez-vous à venir (date >= aujourd'hui)
        final upcomingAppointments = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dateStr = data['date'] as String?;
          final appointmentDate = _parseDate(dateStr);
          final status = data['status'] as String? ?? 'pending';
          
          return appointmentDate != null && 
                 (appointmentDate.isAfter(today) || _isSameDay(appointmentDate, today)) &&
                 (status == 'confirmed' || status == 'pending');
        }).toList()..sort((a, b) {
          final dateA = _parseDate((a.data() as Map<String, dynamic>)['date']);
          final dateB = _parseDate((b.data() as Map<String, dynamic>)['date']);
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });

        if (upcomingAppointments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun rendez-vous à venir',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingAppointments.length > 3 ? 3 : upcomingAppointments.length,
          itemBuilder: (context, index) {
            final appointment = upcomingAppointments[index];
            final data = appointment.data() as Map<String, dynamic>;
            
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get(),
              builder: (context, patientSnapshot) {
                String patientName = 'Patient';
                if (patientSnapshot.hasData && patientSnapshot.data!.exists) {
                  final patientData = patientSnapshot.data!.data() as Map<String, dynamic>;
                  patientName = patientData['fullName'] ?? 'Patient';
                }

                final dateStr = data['date'] as String?;
                final appointmentDate = _parseDate(dateStr);
                final time = data['time'] as String? ?? '--:--';
                final status = data['status'] as String? ?? 'pending';
                
                // Traduire le statut
                String statusFr = 'en_attente';
                if (status == 'confirmed') statusFr = 'confirmé';
                else if (status == 'cancelled') statusFr = 'refusé';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorAppointmentsScreen(initialFilter: 0),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: statusFr == 'en_attente'
                          ? Border.all(color: Colors.orange.shade200, width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(statusFr).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              appointmentDate != null ? '${appointmentDate.day}' : '?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _getStatusColor(statusFr),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      patientName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appointmentDate != null 
                                        ? DateFormat('dd/MM/yyyy').format(appointmentDate)
                                        : 'Date inconnue',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWorkingHoursCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('medecin').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final workingDays = data['workingDays'] as List? ?? [];
        final workingHours = data['workingHours'] as List? ?? [];
        final startTime = data['startTime'] as String? ?? '08:00';
        final endTime = data['endTime'] as String? ?? '18:00';

        return Container(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Horaires de travail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weekDays.map((day) {
                  final isWorking = workingDays.contains(day);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isWorking 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isWorking 
                            ? AppColors.primary 
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isWorking ? FontWeight.w600 : FontWeight.normal,
                        color: isWorking ? AppColors.primary : Colors.grey.shade600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    workingHours.isNotEmpty
                        ? 'Créneaux: ${workingHours.join(', ')}'
                        : 'Horaires: $startTime - $endTime',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActionDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Gérer le rendez-vous'),
        content: const Text('Que souhaitez-vous faire ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAppointmentStatus(appointmentId, 'refusé');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Refuser'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAppointmentStatus(appointmentId, 'confirmé');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      // Traduire le statut pour Firestore
      String firestoreStatus = status == 'confirmé' ? 'confirmed' : 'cancelled';
      
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': firestoreStatus});

      // Récupérer les détails du rendez-vous
      final appointment = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      
      final data = appointment.data() as Map<String, dynamic>;
      
      // Créer une notification pour le patient
      await NotificationService.createNotification(
        userId: data['userId'],
        title: 'Rendez-vous ${status == 'confirmé' ? 'confirmé' : 'refusé'}',
        message: status == 'confirmé'
            ? 'Votre rendez-vous avec ${_userName} a été confirmé'
            : 'Votre rendez-vous avec ${_userName} a été refusé',
        type: 'appointment',
        appointmentId: appointmentId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rendez-vous ${status == 'confirmé' ? 'confirmé' : 'refusé'}'),
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
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Widget _buildBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_filled),
        label: 'Accueil',
      ),
      BottomNavigationBarItem(
        icon: Icon(widget.role == 'medecin' 
            ? Icons.calendar_month_outlined 
            : Icons.calendar_today_outlined),
        activeIcon: Icon(widget.role == 'medecin'
            ? Icons.calendar_month_rounded
            : Icons.calendar_month_rounded),
        label: widget.role == 'medecin' ? 'Planning' : 'RDV',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings_rounded),
        label: 'Paramètres',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            
            switch (index) {
              case 0:
                // Déjà sur l'accueil
                break;
              case 1:
                if (widget.role == 'medecin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorAppointmentsScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentsScreen(),
                    ),
                  );
                }
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFFA0A5BA),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: items,
        ),
      ),
    );
  }

  // ==================== MÉTHODES CORRIGÉES POUR LES PATIENTS ====================

  /// ✅ VERSION CORRIGÉE - Plus d'overflow
  Widget _buildMedicalServices() {
    final services = [
      {
        'icon': Icons.video_camera_back_rounded,
        'label': 'Consultation\nen ligne',
        'gradient': [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
      },
      {
        'icon': Icons.local_hospital_rounded,
        'label': 'Médecine\ngénérale',
        'gradient': [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
      },
      {
        'icon': Icons.medical_services_rounded,
        'label': 'Spécialistes',
        'gradient': [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
      },
      {
        'icon': Icons.local_pharmacy_rounded,
        'label': 'Pharmacie',
        'gradient': [const Color(0xFFFFF3E0), const Color(0xFFFFCC80)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, // 👈 CHANGÉ : plus d'espace vertical
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: service['gradient'] as List<Color>,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12), // 👈 CHANGÉ : padding réduit
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48, // 👈 CHANGÉ : taille réduite
                      height: 48, // 👈 CHANGÉ : taille réduite
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        color: AppColors.primary,
                        size: 24, // 👈 CHANGÉ : taille réduite
                      ),
                    ),
                    const SizedBox(height: 8), // 👈 CHANGÉ : espace réduit
                    Text(
                      service['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, // 👈 CHANGÉ : taille police réduite
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2, // 👈 AJOUTÉ : limite les lignes
                      overflow: TextOverflow.ellipsis, // 👈 AJOUTÉ : évite le débordement
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularDoctors() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medecin').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyDoctorsView();
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length > 5 ? 5 : docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final doctor = doc.data() as Map<String, dynamic>;
            final doctorId = doc.id;

            final fullName = doctor['fullName']?.toString() ?? 'Dr. Inconnu';
            final specialty = doctor['specialty']?.toString() ?? 'Médecin généraliste';
            final hospital = doctor['hospital']?.toString() ?? 'Hôpital non spécifié';
            final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
            final experience = (doctor['experienceYears'] as num?)?.toInt() ?? 0;
            final photoUrl = doctor['photoUrls']?.toString();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailScreen(doctorId: doctorId),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        image: photoUrl != null && photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Center(
                              child: Text(
                                fullName.isNotEmpty ? fullName[0] : 'D',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    fullName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$experience ans',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    hospital,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFFFB800),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '($experience+)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medecin').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptySearchView();
        }

        final allDoctors = snapshot.data!.docs;
        final filteredDoctors = allDoctors.where((doc) {
          final doctor = doc.data() as Map<String, dynamic>;
          final fullName = doctor['fullName']?.toString().toLowerCase() ?? '';
          final specialty = doctor['specialty']?.toString().toLowerCase() ?? '';
          final hospital = doctor['hospital']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return fullName.contains(query) ||
                 specialty.contains(query) ||
                 hospital.contains(query);
        }).toList();

        if (filteredDoctors.isEmpty) {
          return _buildNoResultsView();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    '${filteredDoctors.length} résultat${filteredDoctors.length > 1 ? 's' : ''} trouvé${filteredDoctors.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _showSearchResults = false;
                      });
                      _searchController.clear();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      'Effacer',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doc = filteredDoctors[index];
                  final doctor = doc.data() as Map<String, dynamic>;
                  final doctorId = doc.id;

                  final fullName = doctor['fullName']?.toString() ?? 'Dr. Inconnu';
                  final specialty = doctor['specialty']?.toString() ?? 'Médecin généraliste';
                  final hospital = doctor['hospital']?.toString() ?? 'Hôpital non spécifié';
                  final rating = (doctor['rating'] as num?)?.toDouble() ?? 4.0;
                  final photoUrl = doctor['photoUrls']?.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctorId: doctorId),
                          ),
                        );
                      },
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: photoUrl != null && photoUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Center(
                                child: Text(
                                  fullName.isNotEmpty ? fullName[0] : 'D',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            specialty,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hospital,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: const Color(0xFFFFB800),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyDoctorsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_outlined,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun médecin disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Les médecins seront bientôt ajoutés à la plateforme.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rechercher des médecins',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tapez un nom, une spécialité ou un hôpital',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Aucun médecin ne correspond à "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _showSearchResults = false;
              });
              _searchController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Voir tous les médecins'),
          ),
        ],
      ),
    );
  }

  String _getFirstName() {
    if (_userName.contains(' ')) {
      return _userName.split(' ')[0];
    }
    return _userName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}