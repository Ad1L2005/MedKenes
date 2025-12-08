// lib/pages/doctor_home_page.dart — СУПЕРСОВРЕМЕННАЯ ПАНЕЛЬ ВРАЧА 2025
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medkenes/pages/kenes_ai_chat_page.dart';
import 'package:medkenes/pages/patients_list_tab.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});
  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Дәрігер панелі",
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4)),
        ),
        centerTitle: true,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF06B6D4),
          indicatorWeight: 4,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Жазылу сұраныстары"),
            Tab(text: "Жедел шақырулар"),
            Tab(text: "KenesAI кеңес"),
            Tab(text: "Менің пациенттерім"), // ← новая вкладка
            Tab(text: "Бүгінгі қабылдау"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AppointmentRequestsTab(),
          EmergencyCallsTab(),
          KenesAIForDoctorTab(),
          PatientsListTab(), // ← новая вкладка со списком пациентов
          TodayAppointmentsTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────
// 1. БҮГІНГІ ҚАБЫЛДАУЛАР
// ──────────────────────────────────────
class TodayAppointmentsTab extends StatelessWidget {
  const TodayAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now();
    final todayStr = "${today.day.toString().padLeft(2,'0')}.${today.month.toString().padLeft(2,'0')}.${today.year}";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'confirmed')
          .where('date', isEqualTo: todayStr)
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Бүгін қабылдау жоқ", style: TextStyle(color: Colors.white70, fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFF06B6D4).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF06B6D4),
                  child: Text(data['time'].substring(0,5), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(data['patientName'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text("Растау алынған", style: const TextStyle(color: Colors.green)),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────
// 2. ЖЕДЕЛ ШАҚЫРУЛАР (103)
// ──────────────────────────────────────
class EmergencyCallsTab extends StatelessWidget {
  const EmergencyCallsTab({super.key});

  final List<Map<String, String>> emergencies = const [
    {"name": "Бауыржан Есенов", "address": "Төле би 145, кв. 28", "time": "3 минут бұрын", "status": "Жолда"},
    {"name": "Гүлнар Асанова", "address": "Абай 89, подъезд 3", "time": "7 минут бұрын", "status": "Қабылданды"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, size: 48, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Жедел шақырулар", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Бүгін: 2 белсенді", style: GoogleFonts.manrope(color: Colors.white70)),
                  ],
                ),
              ),
              Text("103", style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...emergencies.map((e) => Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.local_hospital, color: Colors.white)),
                title: Text(e["name"]!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                subtitle: Text(e["address"]!, style: GoogleFonts.manrope(color: Colors.white70)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e["time"]!, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                      child: Text(e["status"]!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ──────────────────────────────────────
// 3. KENESAI КЕҢЕС (доктор тоже может спросить у ИИ)
// ──────────────────────────────────────
class KenesAIForDoctorTab extends StatelessWidget {
  const KenesAIForDoctorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 120, color: const Color(0xFF06B6D4).withOpacity(0.7)),
            const SizedBox(height: 32),
            Text(
              "KenesAI — сіздің көмекшіңіз",
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Диагноз қоюда күмәніңіз бар ма?\nПрепарат таңдау керек пе?\nЖай ғана сұраңыз — мен қазақша жауап беремін",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 17, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KenesAIChatPage()));
              },
              icon: const Icon(Icons.chat_bubble, size: 28),
              label: Text("KenesAI-мен сөйлесу", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentRequestsTab extends StatelessWidget {
  const AppointmentRequestsTab({super.key});

  Future<void> _updateStatus(String docId, String status, BuildContext context) async {
    await FirebaseFirestore.instance.collection('appointments').doc(docId).update({
      'status': status,
      'processedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status == 'confirmed' ? "Қабылдау расталды" : "Қабылдаудан бас тартылды")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Жаңа сұраныстар жоқ", style: GoogleFonts.manrope(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['patientName'], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Күні: ${data['date']} • ${data['time']}", style: GoogleFonts.manrope(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateStatus(doc.id, 'rejected', context),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            child: const Text("Бас тарту", style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(doc.id, 'confirmed', context),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("Растау"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}