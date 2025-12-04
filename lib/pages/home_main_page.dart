// lib/pages/home_main_page.dart — С ПЛАВАЮЩЕЙ КНОПКОЙ KENESAI В УГЛУ!
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'health_profile_page.dart';
import 'ambulance_tracking_page.dart';
import 'kenes_ai_chat_page.dart'; // ← Твой чат с Grok

class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});
  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage> with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;
  final FlutterTts _tts = FlutterTts();

  bool _isHolding = false;
  bool _emergencyConfirmed = false;
  int _countdown = 5;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startEmergencyCall() async {
    if (_emergencyConfirmed) return;
    setState(() => _isHolding = true);
    _progressController.forward(from: 0);
    await _tts.speak("5 секундтан кейін жедел жәрдем шақырылады...");

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        _confirmEmergencyCall();
      } else {
        setState(() => _countdown--);
        Vibration.vibrate(duration: 200);
      }
    });
  }

  void _cancelEmergencyCall() {
    if (!_isHolding || _emergencyConfirmed) return;
    _countdownTimer?.cancel();
    _progressController.reset();
    setState(() {
      _isHolding = false;
      _countdown = 5;
    });
    _tts.speak("Шақыру тоқтатылды");
  }

  void _confirmEmergencyCall() async {
    setState(() {
      _emergencyConfirmed = true;
      _isHolding = false;
    });
    Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 700]);
    await _tts.speak("Жедел жәрдем шақырылды! Бригада жолда, 4 минуттан кейін келеді.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Stack( // ← ВАЖНО: Stack, чтобы кнопка была сверху!
            children: [
              // Основной контент
              Column(
                children: [
                  // Приветствие
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF06B6D4),
                          child: const Icon(Icons.person, size: 34, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Сәлем,", style: GoogleFonts.manrope(color: Colors.white70, fontSize: 16)),
                            Text(user.displayName ?? "Пациент", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Карточка здоровья
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthProfilePage())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monitor_heart, size: 48, color: Colors.white),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Менің денсаулығым", style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text("Келесі қабылдау: 18.03", style: GoogleFonts.manrope(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Большая кнопка 103
                  // Большая кнопка 103 — теперь чуть выше и красивее расположена
Expanded(
  child: Padding(
    padding: const EdgeInsets.only(bottom: 100), // ← Вот это и поднимает кнопку!
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GestureDetector(
          onLongPressStart: (_) => _startEmergencyCall(),
          onLongPressEnd: (_) => _cancelEmergencyCall(),
          onTap: () {
            if (_emergencyConfirmed) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbulanceTrackingPage()));
            }
          },
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isHolding ? 1.0 : 1.0 + (_pulseController.value * 0.05),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _emergencyConfirmed
                          ? [Colors.green[800]!, Colors.green[600]!]
                          : _isHolding
                              ? [Colors.orange[900]!, Colors.red]
                              : [Colors.red, Colors.redAccent],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: (_isHolding || _emergencyConfirmed ? Colors.red : Colors.red).withOpacity(0.8),
                        blurRadius: _isHolding ? 60 : 40,
                        spreadRadius: _isHolding ? 20 : 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isHolding)
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircularProgressIndicator(
                            value: 1 - (_countdown / 5),
                            strokeWidth: 12,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            _emergencyConfirmed
                                ? "Жолда!"
                                : _isHolding
                                    ? "$_countdown"
                                    : "ЖЕДЕЛ ЖӘРДЕМ",
                            style: GoogleFonts.inter(fontSize: _isHolding ? 48 : 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _emergencyConfirmed
                                ? "103 • Картадан көру"
                                : _isHolding
                                    ? "Босатыңыз — отменить"
                                    : "103",
                            style: GoogleFonts.inter(fontSize: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  ),
),
                ],
              ),

                  // Кнопка записи
                  Positioned(
                bottom: 30,
                right: 120,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const KenesAIChatPage()));
                  },
                  backgroundColor: const Color(0xFF06B6D4),
                  elevation: 10,
                  icon: const Icon(Icons.smart_toy, size: 32),
                  label: Text(
                    "KenesAI",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
                ],
              ),

          ),
        ),
      );
  }
}