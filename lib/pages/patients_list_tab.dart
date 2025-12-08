// lib/pages/patients_list_tab.dart — ФИНАЛЬНАЯ СТАБИЛЬНАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medkenes/pages/doctor_patient_detail_page.dart';

class PatientsListTab extends StatelessWidget {
  const PatientsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ЕСЛИ ПОЛЬЗОВАТЕЛЬ ЕЩЁ НЕ АВТОРИЗОВАН — ЖДЁМ
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .orderBy('registeredAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Ловим ошибки (особенно permission-denied)
        if (snapshot.hasError) {
          print("Firestore қатесі: ${snapshot.error}"); // ← смотри в консоль!
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  "Деректер жүктелмеді",
                  style: GoogleFonts.manrope(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  "${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
        }

        final patients = snapshot.data!.docs;

        if (patients.isEmpty) {
          return Center(
            child: Text(
              "Әзірге пациенттер жоқ",
              style: GoogleFonts.manrope(fontSize: 20, color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final doc = patients[index];
            final data = doc.data() as Map<String, dynamic>;

            final String name = data['displayName'] ??
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
            final Timestamp? registeredAt = data['registeredAt'];
            final String date = registeredAt != null
                ? "${registeredAt.toDate().day}.${registeredAt.toDate().month}.${registeredAt.toDate().year}"
                : "Белгісіз";

            return Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF06B6D4),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text(
                  "Тіркелген: $date",
                  style: GoogleFonts.manrope(fontSize: 13, color: Colors.white54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorPatientDetailPage(
                        patientId: doc.id,
                        patientData: data,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}