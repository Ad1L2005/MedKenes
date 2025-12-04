// lib/pages/role_router.dart — ФИНАЛЬНАЯ ВЕРСИЯ ДЛЯ ПАЦИЕНТОВ (2025)
import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Никаких проверок роли — сразу в главный интерфейс пациента
    return const AppBottomNav();
  }
}