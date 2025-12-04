// lib/pages/health_home_page.dart — ГОТОВО, КРАСИВО, КАК В ПРЕМИУМ-ПРИЛОЖЕНИИ 2025
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthHomePage extends StatefulWidget {
  const HealthHomePage({super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text("Менің денсаулығым", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF06B6D4),
          indicatorWeight: 4,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Приёмы"),
            Tab(text: "Документы"),
            Tab(text: "Рецепты"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // 1. ПРИЁМЫ
          AppointmentsTab(),
          // 2. ДОКУМЕНТЫ
          DocumentsTab(),
          // 3. РЕЦЕПТЫ
          PrescriptionsTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// 1. ПРИЁМЫ
// ──────────────────────────────────────────────────
class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> visits = [
      {
        "date": "2025.03.12",
        "doctor": "Айгерім Садықова",
        "specialty": "Эндокринолог",
        "status": "Аяқталды",
        "conclusion": "Гипотиреоз, компенсацияда"
      },
      {
        "date": "2025.02.28",
        "doctor": "Ерлан Қасымов",
        "specialty": "Кардиолог",
        "status": "Аяқталды",
        "conclusion": "АГ 2 дәрежесі"
      },
      {
        "date": "2025.01.15",
        "doctor": "Айжан Мұхтарова",
        "specialty": "Невролог",
        "status": "Аяқталды",
        "conclusion": "Мигрень"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visits.length,
      itemBuilder: (context, i) {
        final v = visits[i];
        return Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              // Позже — открытие SmartDoc / заключения
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${v["doctor"]} — қабылдау ашылады...")),
              );
            },
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF06B6D4),
              child: Text(v["date"]!.substring(8, 10), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
            title: Text(v["doctor"]!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text("${v["specialty"]} • ${v["conclusion"]}", style: GoogleFonts.manrope(color: Colors.white70)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(v["status"]!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────
// 2. ДОКУМЕНТЫ (SmartDocs + выписки)
// ──────────────────────────────────────────────────
class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _documentTile(context, "SmartDoc • Эндокринолог", "12.03.2025", Icons.description, Colors.cyan),
        _documentTile(context, "Выписной эпикриз • Стационар №7", "28.02.2025", Icons.local_hospital, Colors.purple),
        _documentTile(context, "Справка 027/у • Медосмотр", "15.01.2025", Icons.assignment, Colors.orange),
        _documentTile(context, "SmartDoc • Кардиолог", "28.02.2025", Icons.description, Colors.cyan),
      ],
    );
  }

  Widget _documentTile(BuildContext context, String title, String date, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(date, style: GoogleFonts.manrope(color: Colors.white60)),
        trailing: const Icon(Icons.download, color: Color(0xFF06B6D4)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title жүктелуде...")),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// 3. РЕЦЕПТЫ
// ──────────────────────────────────────────────────
class PrescriptionsTab extends StatelessWidget {
  const PrescriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _prescriptionCard(context, "L-Тироксин 100 мкг", "1 таб утром, 30 дней", "12.03.2025 – 11.04.2025", true),
        _prescriptionCard(context, "Эналаприл 10 мг", "1 таб вечером", "28.02.2025 – 28.05.2025", true),
        _prescriptionCard(context, "Суматриптан 100 мг", "При приступе", "15.01.2025 – 15.07.2025", false),
      ],
    );
  }

  Widget _prescriptionCard(BuildContext context, String drug, String dosage, String period, bool active) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: active ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.medication, size: 36, color: active ? Colors.green : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drug, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(dosage, style: GoogleFonts.manrope(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(period, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                child: Text("Белсенді", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}