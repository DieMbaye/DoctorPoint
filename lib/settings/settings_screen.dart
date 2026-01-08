import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String language = 'FR';

  @override
  Widget build(BuildContext context) {
    final userName = 'Die Mbaye'; // plus tard depuis Firestore
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// 🔰 PROFIL CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello 👋',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ⚙️ OPTIONS
          _item(
            icon: Icons.workspace_premium,
            color: Colors.orange,
            title: 'Become a pro member',
            onTap: () {},
          ),

          _switchItem(
            icon: Icons.notifications,
            color: Colors.purple,
            title: 'Notifications',
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),

          _item(
            icon: Icons.language,
            color: Colors.blue,
            title: 'Language',
            trailing: Text(
              language == 'FR' ? 'Français' : 'English',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () => _showLanguageDialog(),
          ),

          _item(
            icon: Icons.favorite,
            color: Colors.green,
            title: 'Favourite doctors',
            onTap: () {},
          ),

          _item(
            icon: Icons.help_outline,
            color: Colors.indigo,
            title: 'FAQs',
            onTap: () {},
          ),

          _item(
            icon: Icons.support_agent,
            color: Colors.teal,
            title: 'Help',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // 🔹 Simple item
  Widget _item({
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }

  // 🔹 Switch item
  Widget _switchItem({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  // 🌍 Language dialog
  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              trailing: language == 'FR'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => language = 'FR');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: language == 'EN'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => language = 'EN');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
