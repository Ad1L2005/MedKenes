// lib/pages/ambulance_home_page.dart — ПАНЕЛЬ БРИГАДЫ СКОРОЙ ПОМОЩИ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ambulance_call_details_page.dart'; // ← создадим на следующем шаге

class AmbulanceHomePage extends StatelessWidget {
  const AmbulanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Жедел жәрдем бригадасы",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
          ),
        ),
        actions: [
          IconButton(
  icon: const Icon(Icons.logout, color: Colors.white),
  onPressed: () {
    // Красивый диалог подтверждения (как у тебя в профиле)
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
          "Дәрігер панелінен шығасыз ба?\nБарлық сессия аяқталады.",
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
            ),
            onPressed: () async {
              Navigator.of(ctx).pop(); // закрываем диалог

              await FirebaseAuth.instance.signOut();

              // ВАЖНО: ПОЛНЫЙ СБРОС НАВИГАЦИИ НА ЛОГИН
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',  // или '/'
                  (route) => false,
                );
              }
            },
            child: Text("Иә, шығу", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  },
),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Большая красная иконка
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent, width: 4),
                ),
                child: const Icon(Icons.emergency, size: 100, color: Colors.redAccent),
              ),
              const SizedBox(height: 40),

              Text(
                "Сәлем, ${user.displayName ?? 'Бригада'}!",
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                "Сіз — MedKenes жедел жәрдем бригадасы\nЖаңа шақыруларды күтіңіз...",
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 18, color: Colors.white70),
              ),

              const SizedBox(height: 60),

              // ГЛАВНАЯ КНОПКА — ПОСТУПИЛ ВЫЗОВ
              SizedBox(
                width: double.infinity,
                height: 90,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AmbulanceCallDetailsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 20,
                    shadowColor: Colors.red.withOpacity(0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber, size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Text(
                        "ЖАҢА ШАҚЫРУ КЕЛДІ!",
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Нажмите кнопку — открыть вызов",
                style: GoogleFonts.manrope(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}