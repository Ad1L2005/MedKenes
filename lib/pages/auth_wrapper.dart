// lib/pages/auth_wrapper.dart — ФИКСИМ АВТОЛОГИН
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'role_router.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Пока грузится — лоадер
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4))),
          );
        }

        // ЕСЛИ ПОЛЬЗОВАТЕЛЬ ЕСТЬ — идём в приложение
        if (snapshot.hasData && snapshot.data != null) {
          return const RoleRouter();
        }

        // ВО ВСЕХ ОСТАЛЬНЫХ СЛУЧАЯХ — ЛОГИН
        return const LoginPage();
      },
    );
  }
}