import 'package:flutter/material.dart';
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
  String? gender;
  DateTime? birthDate;
  final addressCtrl = TextEditingController();
  final AuthService auth = AuthService();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurer le profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: gender,
              hint: const Text('Genre'),
              items: const [
                DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                DropdownMenuItem(value: 'Femme', child: Text('Femme')),
              ],
              onChanged: (v) => setState(() => gender = v),
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                birthDate == null
                    ? 'Date de naissance'
                    : birthDate!.toLocal().toString().split(' ')[0],
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => birthDate = d);
              },
            ),

            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: loading
                    ? null
                    : () async {
                        if (gender == null ||
                            birthDate == null ||
                            addressCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tous les champs sont requis'),
                            ),
                          );
                          return;
                        }

                        setState(() => loading = true);
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
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Terminer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
