// lib/pages/health_profile_page.dart — ТЕЛЕФОН ОТОБРАЖАЕТСЯ КАК ВСЕ ОСТАЛЬНЫЕ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HealthProfilePage extends StatelessWidget {
  HealthProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
      ),
      body: userId == null
          ? const Center(child: Text("Кіру қажет", style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('patients').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
                }

                final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

                final birthDate = data['birthDate'] != null
                    ? (data['birthDate'] as Timestamp).toDate()
                    : null;
                final age = birthDate != null
                    ? DateTime.now().year - birthDate.year
                    : null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Главная карточка
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                data['fullName']?.toString().isNotEmpty == true
                                    ? data['fullName'][0].toUpperCase()
                                    : "?",
                                style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data['fullName'] ?? "Пациент",
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "${age ?? '?'} жас • ${data['bloodType'] ?? 'Белгісіз'}",
                              style: GoogleFonts.manrope(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      _infoCard("ИИН", data['iin'] ?? "Толтырылмаған", Icons.credit_card),
                      _infoCard("Телефон", data['phone'] ?? "Толтырылмаған", Icons.phone),
                      _infoCard("Мекенжай", data['address'] ?? "Толтырылмаған", Icons.location_on),
                      _infoCard("Туған күні", birthDate != null ? DateFormat('dd.MM.yyyy').format(birthDate) : "Толтырылмаған", Icons.cake),
                      _infoCard("Қан тобы", data['bloodType'] ?? "Толтырылмаған", Icons.bloodtype),

                      const SizedBox(height: 40),
                      const SizedBox(height: 32),
Text("Медицинская информация (по данным врачей)", 
     style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70)),

const SizedBox(height: 16),

_infoCard("Аллергические реакции", 
    data['allergies'] ?? "Не выявлено", 
    Icons.warning_amber, 
    color: Colors.orangeAccent),

_infoCard("Хронические заболевания", 
    data['chronicDiseases'] ?? "Не выявлено", 
    Icons.local_hospital, 
    color: Colors.redAccent),

_infoCard("Перенесённые операции", 
    data['surgeries'] ?? "Не проводились", 
    Icons.healing, 
    color: Colors.purpleAccent),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, {Color color = const Color(0xFF06B6D4)}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ],
    ),
  );
}
}