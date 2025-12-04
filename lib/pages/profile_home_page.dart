// lib/pages/profile_home_page.dart — РАБОТАЕТ 100%, ВЫХОД С КРАСИВЫМ ПОДТВЕРЖДЕНИЕМ
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text("Профиль", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // АВАТАР + ФИО + ТЕЛЕФОН
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF06B6D4),
              child: Text(
                (user?.displayName ?? "М")[0].toUpperCase(),
                style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? "Пациент",
              style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              user?.phoneNumber ?? "+7 (707) 728 78 97",
              style: GoogleFonts.manrope(fontSize: 18, color: const Color(0xFF06B6D4), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // СТАТУС ВЫСОКОГО РИСКА
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Жоғары қауіп тобы: Гипотиреоз + АГ 2 дәрежесі",
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ОСНОВНЫЕ ПУНКТЫ
            _profileTile(
              icon: Icons.person_outline,
              title: "Жеке мәліметтер",
              subtitle: "ФИО, ИИН, туған күн, қан тобы",
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.favorite_border,
              title: "Медициналық деректер",
              subtitle: "Созылмалы аурулар, аллергия, дәрілер",
              color: Colors.red,
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.shield_moon,
              title: "HighRisk режим",
              subtitle: "Автоматты 103 + GPS + сирена при падении",
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.red),
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.family_restroom,
              title: "Жақын туыстар",
              subtitle: "2 адам • Авто-қоңырау при вызове 103",
              onTap: () {},
            ),

            const Divider(height: 40, color: Colors.white10),

            _profileTile(
              icon: Icons.language,
              title: "Тіл • Қазақша",
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.notifications_outlined,
              title: "Хабарламалар",
              subtitle: "Напоминания о приёмах и лекарствах",
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.help_outline,
              title: "Көмек және қолдау",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ВЫХОД — С КРАСИВЫМ ДИАЛОГОМ
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  child: const Icon(Icons.logout, color: Colors.redAccent),
                ),
                title: Text(
                  "Шығу",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.redAccent),
                ),
                onTap: () {
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
                            child: Text(
                              "Шығуды растаңыз",
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        "Сіз шынымен тіркелгіден шыққыңыз келе ме?\nHighRisk режимі және 103 қоңырауы өшіріледі.",
                        style: GoogleFonts.manrope(fontSize: 16, color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text("Жоқ", style: GoogleFonts.inter(fontSize: 18, color: Colors.white60)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            FirebaseAuth.instance.signOut();
                          },
                          child: Text(
                            "Иә, шығу",
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ОТДЕЛЬНАЯ ФУНКЦИЯ ДЛЯ КАРТОЧЕК
  Widget _profileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (color ?? const Color(0xFF06B6D4)).withOpacity(0.2),
          child: Icon(icon, color: color ?? const Color(0xFF06B6D4)),
        ),
        title: Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.manrope(fontSize: 14, color: Colors.white60))
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white60),
        onTap: onTap,
      ),
    );
  }
}