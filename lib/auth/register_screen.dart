import 'package:doctor_point/auth/login_screen.dart';
import 'package:doctor_point/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../profile/setup_profile_screen.dart';
import '../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final String initialRole;
  
  const RegisterScreen({super.key, this.initialRole = 'patient'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs communs
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  
  // Contrôleurs pour les champs médecin
  final aboutCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final hospitalCtrl = TextEditingController();
  final specialtyCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();
  final patientsCtrl = TextEditingController();
  
  // Pour les frais
  final messageFeeCtrl = TextEditingController();
  final videoFeeCtrl = TextEditingController();
  final voiceFeeCtrl = TextEditingController();
  
  // Variables pour les jours de travail
  List<String> selectedWorkingDays = [];
  final List<String> weekDays = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];
  
  // Variables pour les horaires
  List<String> workingHours = [];
  
  String selectedRole = 'patient';
  String selectedGender = 'Homme';
  final AuthService auth = AuthService();
  
  bool loading = false;
  bool hidePassword = true;
  bool acceptTerms = false;
  
  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildRoleSelector(),
                const SizedBox(height: 30),
                _buildStepsIndicator(),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildGenderField(),
                      const SizedBox(height: 20),
                      
                      // Champs spécifiques au médecin
                      if (selectedRole == 'medecin') ...[
                        const Divider(height: 40, thickness: 1),
                        Text(
                          'Informations professionnelles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAboutField(),
                        const SizedBox(height: 20),
                        _buildSpecialtyField(),
                        const SizedBox(height: 20),
                        _buildExperienceField(),
                        const SizedBox(height: 20),
                        _buildHospitalField(),
                        const SizedBox(height: 20),
                        _buildPatientsField(),
                        const SizedBox(height: 20),
                        
                        Text(
                          'Honoraires (FCFA)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildFeesFields(),
                        const SizedBox(height: 20),
                        
                        Text(
                          'Jours de travail',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildWorkingDaysSelector(),
                        const SizedBox(height: 20),
                        
                        Text(
                          'Horaires de travail',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildWorkingHoursFields(),
                      ],
                      
                      const SizedBox(height: 24),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 32),
                      _buildRegisterButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildDivider(),
                const SizedBox(height: 32),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 16),
        Text(
          'Créer votre compte',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedRole == 'patient' 
              ? 'Rejoignez la communauté DoctorPoint en tant que patient'
              : 'Rejoignez la communauté DoctorPoint en tant que médecin',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRole = 'patient'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedRole == 'patient' 
                      ? AppColors.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: selectedRole == 'patient' 
                          ? Colors.white 
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Patient',
                      style: TextStyle(
                        color: selectedRole == 'patient' 
                            ? Colors.white 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRole = 'medecin'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedRole == 'medecin' 
                      ? AppColors.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_rounded,
                      color: selectedRole == 'medecin' 
                          ? Colors.white 
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Médecin',
                      style: TextStyle(
                        color: selectedRole == 'medecin' 
                            ? Colors.white 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepCircle(1, 'Informations', true),
              _buildStepLine(true),
              _buildStepCircle(2, 'Profil', false),
              _buildStepLine(false),
              _buildStepCircle(3, 'Confirmation', false),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            selectedRole == 'patient'
                ? 'Étape 1/3 : Informations patient'
                : 'Étape 1/3 : Informations médecin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedRole == 'patient'
                ? 'Remplissez vos informations personnelles'
                : 'Remplissez vos informations personnelles et professionnelles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.border,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom complet *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameCtrl,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            if (value.split(' ').length < 2) {
              return 'Veuillez entrer votre nom complet';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: selectedRole == 'patient' 
                ? 'Jean Dupont' 
                : 'Dr Jean Dupont',
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse email *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre email';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'exemple@email.com',
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Icon(
                Icons.email_rounded,
                color: AppColors.primary,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (value.length < 7) {
              return 'Numéro invalide';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '77 123 45 67',
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Icon(
                Icons.phone_rounded,
                color: AppColors.primary,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mot de passe *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passCtrl,
          obscureText: hidePassword,
          validator: (value) {
            if (value == null || value.length < 8) {
              return 'Minimum 8 caractères';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Au moins une majuscule';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Au moins un chiffre';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => hidePassword = !hidePassword);
              },
              icon: Icon(
                hidePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textSecondary,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordRequirement(
                'Minimum 8 caractères',
                passCtrl.text.length >= 8,
              ),
              _buildPasswordRequirement(
                'Au moins une majuscule',
                RegExp(r'[A-Z]').hasMatch(passCtrl.text),
              ),
              _buildPasswordRequirement(
                'Au moins un chiffre',
                RegExp(r'[0-9]').hasMatch(passCtrl.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? Colors.green : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: AppColors.primary,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
            items: ['Homme', 'Femme', 'Autre'].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // Champs spécifiques au médecin
  Widget _buildAboutField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: aboutCtrl,
          maxLines: 3,
          validator: (value) {
            if (selectedRole == 'medecin' && (value == null || value.isEmpty)) {
              return 'Veuillez décrire votre spécialité';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Spécialiste en...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spécialité *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: specialtyCtrl,
          validator: (value) {
            if (selectedRole == 'medecin' && (value == null || value.isEmpty)) {
              return 'Veuillez entrer votre spécialité';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Cardiologie, Dermatologie, etc.',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Années d\'expérience *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: experienceCtrl,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (selectedRole == 'medecin' && (value == null || value.isEmpty)) {
              return 'Veuillez entrer votre expérience';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '6',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hôpital / Cabinet *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: hospitalCtrl,
          validator: (value) {
            if (selectedRole == 'medecin' && (value == null || value.isEmpty)) {
              return 'Veuillez entrer votre établissement';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Hopital Principal de Dakar',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de patients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: patientsCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '18',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeesFields() {
    return Row(
      children: [
        Expanded(
          child: _buildFeeField('Message', messageFeeCtrl, '5000'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFeeField('Vidéo', videoFeeCtrl, '15000'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFeeField('Voix', voiceFeeCtrl, '10000'),
        ),
      ],
    );
  }

  Widget _buildFeeField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingDaysSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weekDays.map((day) {
        final isSelected = selectedWorkingDays.contains(day);
        return FilterChip(
          label: Text(day),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedWorkingDays.add(day);
              } else {
                selectedWorkingDays.remove(day);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkingHoursFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimeField('Heure de début', startTimeCtrl, '08:00'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTimeField('Heure de fin', endTimeCtrl, '18:00'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Ou sélectionnez les horaires spécifiques',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final hour = '${8 + index}:00';
              final isSelected = workingHours.contains(hour);
              return FilterChip(
                label: Text(hour),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      workingHours.add(hour);
                    } else {
                      workingHours.remove(hour);
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: (value) {
            setState(() => acceptTerms = value ?? false);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => acceptTerms = !acceptTerms);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'J\'accepte les '),
                    TextSpan(
                      text: 'Conditions d\'utilisation',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'Politique de confidentialité',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' de DoctorPoint'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: (loading || !acceptTerms) ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: loading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedRole == 'patient' 
                        ? Icons.person_add_alt_1_rounded 
                        : Icons.medical_services_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    selectedRole == 'patient'
                        ? 'Créer mon compte patient'
                        : 'Créer mon compte médecin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Déjà inscrit ?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte ? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'Se connecter',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      if (selectedRole == 'patient') {
        // Inscription patient
        final user = await auth.registerPatient(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
          fullName: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          gender: selectedGender,
        );

        // Dans la méthode _register(), après l'inscription du médecin :

if (!mounted) return;
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => HomeScreen(
      userName: nameCtrl.text.trim(),
      role: 'medecin', // 👈 Important : passer le rôle
    ),
  ),
);
      } else {
        // Inscription médecin
        final user = await auth.registerDoctor(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
          fullName: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          gender: selectedGender,
          about: aboutCtrl.text.trim(),
          specialty: specialtyCtrl.text.trim(),
          experienceYears: int.tryParse(experienceCtrl.text.trim()) ?? 0,
          hospital: hospitalCtrl.text.trim(),
          patients: int.tryParse(patientsCtrl.text.trim()) ?? 0,
          fees: {
            'message': int.tryParse(messageFeeCtrl.text.trim()) ?? 5000,
            'video': int.tryParse(videoFeeCtrl.text.trim()) ?? 15000,
            'voice': int.tryParse(voiceFeeCtrl.text.trim()) ?? 10000,
          },
          workingDays: selectedWorkingDays,
          workingHours: workingHours.isNotEmpty ? workingHours : null,
          startTime: startTimeCtrl.text.trim().isNotEmpty ? startTimeCtrl.text.trim() : '08:00',
          endTime: endTimeCtrl.text.trim().isNotEmpty ? endTimeCtrl.text.trim() : '18:00',
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SetupProfileScreen(uid: user!.uid, role: 'medecin'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('email-already-in-use')
                ? 'Cet email est déjà utilisé'
                : 'Erreur lors de l\'inscription: ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    setState(() => loading = false);
  }
}