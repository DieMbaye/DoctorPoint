import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../home/home_screen.dart';
import '../core/constants/app_colors.dart';

class SetupProfileScreen extends StatefulWidget {
  final String uid;
  const SetupProfileScreen({super.key, required this.uid});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final AuthService auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String? gender;
  DateTime? birthDate;
  final addressCtrl = TextEditingController();
  bool loading = false;

  /// 📅 DATE PICKER
  Future<void> pickDate() async {
    final initialDate = DateTime.now().subtract(const Duration(days: 365 * 25));
    final date = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => birthDate = date);
    }
  }

  /// ✅ SUBMIT
  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      if (gender == null || birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez compléter tous les champs'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      setState(() => loading = true);

      try {
        await auth.completeProfile(
          uid: widget.uid,
          gender: gender!,
          birthDate: birthDate!,
          address: addressCtrl.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(userName: ''),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Compléter votre profil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Dernière étape pour accéder à DoctorPoint',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Progress Indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Étape 3/3 : Informations personnelles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ces informations nous aident à mieux vous accompagner',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Gender Field
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: gender,
                        isExpanded: true,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Sélectionnez votre genre',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Homme',
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Homme'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Femme',
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Femme'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Autre',
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Autre'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => gender = value);
                          }
                        },
                        dropdownColor: Colors.white,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Birth Date Field
                  Text(
                    'Date de naissance *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              birthDate == null
                                  ? 'Sélectionnez votre date de naissance'
                                  : DateFormat('dd MMMM yyyy', 'fr_FR').format(birthDate!),
                              style: TextStyle(
                                color: birthDate == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (birthDate != null)
                            IconButton(
                              onPressed: () => setState(() => birthDate = null),
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Address Field
                  Text(
                    'Adresse',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ex: Dakar, Sénégal',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                        ),
                      ),
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

                  const SizedBox(height: 40),

                  /// Complete Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
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
                                  Icons.check_circle_rounded,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Terminer la configuration',
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }
}