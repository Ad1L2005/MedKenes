// lib/pages/role_router.dart — УМНЫЙ РОУТЕР + НИЖНЯЯ ПАНЕЛЬ ДЛЯ ПАЦИЕНТОВ
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medkenes/pages/ambulance_home_page.dart';
import 'app_bottom_nav.dart';        // ← Вот она, твоя красота!
import 'doctor_home_page.dart';     // ← Для врачей

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        // Пока грузим роль
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4))),
          );
        }

        final role = snapshot.data?['role'] as String? ?? 'patient';

        // ЕСЛИ ДОКТОР — отдельная страница
        if (role == 'doctor') {
          return const DoctorHomePage();
        }
        if (role == 'ambulance') {
  return const AmbulanceHomePage(); // ← НОВАЯ СТРАНИЦА
}

        // ЕСЛИ ПАЦИЕНТ — главная с нижней панелью
        return const AppBottomNav();
      },
    );
  }
}