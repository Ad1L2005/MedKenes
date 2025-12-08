// lib/pages/profile_home_page.dart — ЧИСТАЯ ВЕРСИЯ (ТОЛЬКО САМОЕ ВАЖНОЕ)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medkenes/pages/personal_info_page.dart';

class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Профиль",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('patients').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // АВАТАР + ФИО + ТЕЛЕФОН
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF06B6D4),
                  child: Text(
                    (data['fullName']?.toString().isNotEmpty == true
                            ? data['fullName']
                            : user?.displayName ?? "М")[0]
                        .toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data['fullName']?.toString().isNotEmpty == true
                      ? data['fullName']
                      : user?.displayName ?? "Пациент",
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 30),

                // ЖЕКЕ МӘЛІМЕТТЕР
                _profileTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: "Жеке мәліметтер",
                  subtitle: data.isEmpty
                      ? "Толтырыңыз"
                      : "${data['fullName'] ?? ''} • ${data['iin'] ?? ''}",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage())),
                ),

                const Divider(height: 50, color: Colors.white10),

                // НАСТРОЙКИ
                _profileTile(context: context, icon: Icons.language, title: "Тіл • Қазақша", onTap: () {}),
                _profileTile(context: context, icon: Icons.notifications_outlined, title: "Хабарламалар", subtitle: "Напоминания о приёмах", onTap: () {}),
                _profileTile(context: context, icon: Icons.help_outline, title: "Көмек және қолдау", onTap: () {}),

                const SizedBox(height: 30),

                // ВЫХОД
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      child: const Icon(Icons.logout, color: Colors.redAccent),
                    ),
                    title: Text("Шығу", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
          child: Icon(icon, color: const Color(0xFF06B6D4)),
        ),
        title: Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.manrope(fontSize: 14, color: Colors.white60))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white60),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.redAccent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text("Шығуды растаңыз", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
        content: Text("Сіз шынымен тіркелгіден шыққыңыз келе ме?", style: GoogleFonts.manrope(fontSize: 16, color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Жоқ", style: GoogleFonts.inter(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: Text("Иә, шығу", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}