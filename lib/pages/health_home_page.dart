// lib/pages/health_home_page.dart — ТОЛЬКО НАСТОЯЩИЕ ДОКУМЕНТЫ ОТ ВРАЧА
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medkenes/services/pdf_service.dart';

class HealthHomePage extends StatefulWidget {
  const HealthHomePage({super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? patientId = FirebaseAuth.instance.currentUser?.uid;

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
    if (patientId == null) {
      return const Scaffold(body: Center(child: Text("Кіру қажет", style: TextStyle(color: Colors.white))));
    }

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
        children: [
          // 1. Приёмы — можно оставить пустым или позже заполнить
          const Center(child: Text("Приёмы скоро будут здесь", style: TextStyle(color: Colors.white70))),

          // 2. ДОКУМЕНТЫ — ТОЛЬКО НАСТОЯЩИЕ SMARTDOC ОТ ВРАЧА
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('smartdocs')
                .where('patientId', isEqualTo: patientId)
                .where('confirmed', isEqualTo: true)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 80, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text("Әзірге құжаттар жоқ", style: GoogleFonts.manrope(fontSize: 18, color: Colors.white70)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  final doc = snapshot.data!.docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['createdAt'] as Timestamp).toDate();
                  final doctorName = data['doctorName'] ?? 'Дәрігер';
                  final content = data['content'] as String;

                  return Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF06B6D4),
                        child: Text("${date.day}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                      title: Text("SmartDoc • $doctorName", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                      subtitle: Text("${date.day}.${date.month}.${date.year}", style: GoogleFonts.manrope(color: Colors.white60)),
                      trailing: const Icon(Icons.visibility, color: Color(0xFF06B6D4)),
                      onTap: () {
                        // Открываем сам документ
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.9,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3))),
                                const SizedBox(height: 16),
                                Text("SmartDoc • ${date.day}.${date.month}.${date.year}", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4))),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Card(
                                    color: const Color(0xFF1E293B),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: SingleChildScrollView(
                                        child: Text(content, style: GoogleFonts.manrope(fontSize: 16, height: 1.7, color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
  onPressed: () async {
    Map<String, dynamic> patientData = {};
    String patientName = 'Пациент';

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      if (userDoc.exists) {
        patientData = userDoc.data() as Map<String, dynamic>;
        patientName = patientData['fullName'] ?? 'Пациент';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Деректер жүктелмеді")),
      );
    }

    // ИСПРАВЛЕНО: правильное объявление
    final Timestamp? birthTimestamp = patientData['birthDate'] is Timestamp
        ? patientData['birthDate'] as Timestamp
        : null;

    final String birthStr = birthTimestamp != null
        ? "${birthTimestamp.toDate().day.toString().padLeft(2, '0')}.${birthTimestamp.toDate().month.toString().padLeft(2, '0')}.${birthTimestamp.toDate().year}"
        : '—';

    final String iin = patientData['iin']?.toString() ?? '—';
    final String gender = patientData['gender'] == 'male' ? 'Ер' : 'Әйел';
    final String phone = patientData['phone']?.toString() ?? '—';

    await PdfService.generateOfficialSmartDoc(
      patientName: patientName,
      doctorName: doctorName,
      patientIIN: iin,
      patientGender: gender,
      patientBirthDate: birthStr,
      patientPhone: phone,
      content: content,
    );
  },
  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
  label: const Text("PDF жүктеу", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF06B6D4),
    padding: const EdgeInsets.symmetric(vertical: 18),
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  ),
),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          // 3. РЕЦЕПТЫ — можно оставить пустым пока
          const Center(child: Text("Рецепты скоро будут здесь", style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

