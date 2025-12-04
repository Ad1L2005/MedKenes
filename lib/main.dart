// lib/main.dart — АБСОЛЮТНО ПРАВИЛЬНАЯ ВЕРСИЯ 2025 (БЕЗ КРАСНОГО ЭКРАНА)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth_wrapper.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/role_router.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MedKenesApp());
}

class MedKenesApp extends StatelessWidget {
  const MedKenesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedKenes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF06B6D4)),
        fontFamily: 'GoogleSans',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),

      // ВНИМАНИЕ: ЛИБО home, ЛИБО initialRoute + routes
      // МЫ ВЫБИРАЕМ routes + initialRoute — ЭТО ПРАВИЛЬНЫЙ ПУТЬ

      initialRoute: '/',                    // ← стартуем с AuthWrapper
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const RoleRouter(),  // ← если захочешь потом
      },

      // home: УДАЛИЛ СОВСЕМ — ОН БЫЛ ПРИЧИНОЙ КРАСНОГО ЭКРАНА
    );
  }
}