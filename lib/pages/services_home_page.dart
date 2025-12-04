// lib/pages/services_home_page.dart — ЗАПИСЬ НА ПРИЁМ + БУДУЩИЕ ВИЗИТЫ + КЛИНИКИ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});

  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Дәрігерге жазылу", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF06B6D4),
          indicatorWeight: 4,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Жаңа жазылу"),
            Tab(text: "Менің жазылуларым"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NewAppointmentTab(),
          MyAppointmentsTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// ВКЛАДКА: ЖАҢА ЖАЗЫЛУ
// ──────────────────────────────────────────────────
class NewAppointmentTab extends StatelessWidget {
  const NewAppointmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Поиск
        TextField(
          decoration: InputDecoration(
            hintText: "Дәрігер, мамандық немесе клиника іздеу...",
            hintStyle: GoogleFonts.manrope(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF06B6D4)),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 24),

        // Популярные специальности
        Text("Танымал мамандықтар", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _specialtyChip("Терапевт", Icons.local_hospital),
            _specialtyChip("Кардиолог", Icons.favorite),
            _specialtyChip("Эндокринолог", Icons.biotech),
            _specialtyChip("Невролог", Icons.psychology),
            _specialtyChip("Офтальмолог", Icons.visibility),
            _specialtyChip("ЛОР", Icons.hearing),
            _specialtyChip("Гинеколог", Icons.woman),
            _specialtyChip("Уролог", Icons.male),
          ],
        ),
        const SizedBox(height: 32),

        // Ближайшие клиники
        Text("Жақын жердегі клиникалар", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _clinicCard(context, "Медикер", "Алмалы ауданы, 2.3 км", "4.8"),
        _clinicCard(context, "iClinic Premium", "Медеу ауданы, 4.1 км", "4.9"),
        _clinicCard(context, "ГП №5", "Бостандык ауданы, 5.6 км", "4.3"),
      ],
    );
  }

  Widget _specialtyChip(String title, IconData icon) {
    return ActionChip(
      backgroundColor: const Color(0xFF1E293B),
      avatar: Icon(icon, size: 20, color: const Color(0xFF06B6D4)),
      label: Text(title, style: GoogleFonts.manrope(color: Colors.white)),
      onPressed: () {
        // Позже — переход к списку врачей
      },
    );
  }

  Widget _clinicCard(BuildContext context, String name, String distance, String rating,) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Row(
          children: [
            Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        subtitle: Text("$distance • ★ $rating", style: GoogleFonts.manrope(color: Colors.white60)),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$name — таңдау ашылады...")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06B6D4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text("Жазылу", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// ВКЛАДКА: МЕНІҢ ЖАЗЫЛУЛАРЫМ
// ──────────────────────────────────────────────────
class MyAppointmentsTab extends StatelessWidget {
  const MyAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> upcoming = [
      {
        "date": "2025.03.18",
        "time": "14:30",
        "doctor": "Айгерім Садықова",
        "specialty": "Эндокринолог",
        "clinic": "Медикер",
        "status": "active",
      },
      {
        "date": "2025.04.02",
        "time": "10:00",
        "doctor": "Ерлан Қасымов",
        "specialty": "Кардиолог",
        "clinic": "iClinic Premium",
        "status": "active",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcoming.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text("Алдағы қабылдаулар", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          );
        }
        final app = upcoming[i - 1];
        return Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.calendar_today, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${app["date"]} • ${app["time"]}", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("${app["doctor"]} • ${app["specialty"]}", style: GoogleFonts.manrope(color: Colors.white70)),
                          Text(app["clinic"], style: GoogleFonts.manrope(fontSize: 14, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Басқа уақыт таңдау...")),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF06B6D4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Ауыстыру", style: GoogleFonts.inter(color: const Color(0xFF06B6D4))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Жазылу тоқтатылды"), backgroundColor: Colors.red),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Бас тарту", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
  }
}