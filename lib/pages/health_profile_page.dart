// lib/pages/health_profile_page.dart — МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА 2025
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthProfilePage extends StatelessWidget {
  const HealthProfilePage({super.key});

  // Вымышленные, но реалистичные данные (потом заменишь на Firestore)
  final Map<String, dynamic> patientData = const {
    "fullName": "Адиль Нургожа",
    "iin": "000101550123",
    "birthDate": "01.01.2000",
    "age": 25,
    "bloodType": "O(I) Rh+",
    "chronic": ["Сахарный диабет 1 типа", "Бронхиальная астма"],
    "allergies": ["Пенициллин", "Арахис"],
    "lastVisit": "12 марта 2025 • Терапевт, ГКП №7",
    "nextVisit": "18 марта 2025 • Эндокринолог, 14:30",
    "riskLevel": "Высокий",
    "phone": "+7 (707) 123-45-67",
    "address": "г. Алматы, ул. Шевченко 28, кв. 15",
  };

  @override
  Widget build(BuildContext context) {
    final data = patientData;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Менің денсаулығым", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Главная карточка пациента
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Text("АН", style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4)))),
                  const SizedBox(height: 16),
                  Text(data["fullName"], style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("${data["age"]} жас • ${data["Type"]}", style: GoogleFonts.manrope(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                    child: Text("ЖОҒАРЫ ТӘУЕКЕЛ ТОБЫ", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Блоки с данными
            _infoCard("ИИН", data["iin"], Icons.credit_card),
            _infoCard("Телефон", data["phone"], Icons.phone),
            _infoCard("Мекенжай", data["address"], Icons.location_on),

            const SizedBox(height: 24),

            // Хронические заболевания
            _sectionTitle("Созылмалы аурулар"),
            ...data["chronic"].map<Widget>((disease) => _diseaseChip(disease, Colors.orange)),

            const SizedBox(height: 16),

            // Аллергии
            _sectionTitle("Аллергия"),
            ...data["allergies"].map<Widget>((allergy) => _diseaseChip(allergy, Colors.red)),

            const SizedBox(height: 24),

            // Последний и следующий приём
            _visitCard("Соңғы қабылдау", data["lastVisit"], Icons.history),
            const SizedBox(height: 12),
            _visitCard("Келесі қабылдау", data["nextVisit"], Icons.event_available, color: Colors.green),

            const SizedBox(height: 40),

            // Кнопка "Показать фельдшеру" — для экстренных случаев
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Медкарта скопирована в буфер обмена"), backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(Icons.share, size: 28),
                label: Text("ФЕЛЬДШЕРГЕ КӨРСЕТУ", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // КЛЮЧЕВОЕ: начинаем с верха
      children: [
        Icon(icon, color: const Color(0xFF06B6D4), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3, // чуть больше расстояние между строками
                ),
                softWrap: true,  // разрешаем перенос
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _diseaseChip(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.5))),
        child: Text(text, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _visitCard(String title, String details, IconData icon, {Color color = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Text(details, style: GoogleFonts.manrope(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}