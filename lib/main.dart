// lib/main.dart — ВСЕГДА СТАРТ С LOGIN, НО С УМНОЙ ЛОГИКОЙ
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/role_router.dart';
import 'pages/auth_wrapper.dart';
import 'services/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),

      // ВСЕГДА начинаем с LoginPage
      home: const LoginPage(),

      // Остальные маршруты — на всякий случай (можно потом расширять)
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const RoleRouter(),
        '/auth': (context) => const AuthWrapper(), // если захочешь вернуть
      },
    );
  }
}