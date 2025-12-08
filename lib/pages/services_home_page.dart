// lib/pages/services_home_page.dart — РАБОЧАЯ ВЕРСИЯ (все ошибки исправлены)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});

  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
// ВКЛАДКА: ЖАҢА ЖАЗЫЛУ — 100% РАБОЧАЯ!
class NewAppointmentTab extends StatefulWidget {
  const NewAppointmentTab({super.key});
  @override
  State<NewAppointmentTab> createState() => _NewAppointmentTabState();
}

class _NewAppointmentTabState extends State<NewAppointmentTab> {
  String? selectedDoctorId;
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> timeSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "14:00", "14:30", "15:00", "15:30", "16:00", "16:30"
  ];

  Future<void> _sendRequest(String doctorId, String doctorName) async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Күні мен уақытын таңдаңыз")),
      );
      return;
    }

    final patientId = FirebaseAuth.instance.currentUser!.uid;
    final patientDoc = await FirebaseFirestore.instance.collection('users').doc(patientId).get();
    final patientName = patientDoc['fullName'] ?? patientDoc['firstName'] ?? 'Пациент';

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'date': "${selectedDate!.day.toString().padLeft(2,'0')}.${selectedDate!.month.toString().padLeft(2,'0')}.${selectedDate!.year}",
        'time': selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Сұраныс жіберілді!",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Сбрасываем выбор
      setState(() {
        selectedDoctorId = null;
        selectedDate = null;
        selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Қате! Қайтадан көріңіз"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
        }

        final doctors = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Дәрігер таңдаңыз", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // СПИСОК ВРАЧЕЙ
            ...doctors.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = selectedDoctorId == doc.id;

              return Card(
                color: isSelected ? const Color(0xFF06B6D4).withOpacity(0.25) : const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      selectedDoctorId = doc.id;
                      selectedDate = null;
                      selectedTime = null;
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF06B6D4),
                    child: Text(
                      data['firstName']?[0].toUpperCase() ?? "?",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim().isEmpty
                        ? "Дәрігер"
                        : "${data['firstName']} ${data['lastName']}",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  subtitle: Text(
                    "${data['specialty'] ?? 'Мамандығы көрсетілмеген'} • ${data['clinic'] ?? 'Клиника жоқ'}",
                    style: GoogleFonts.manrope(color: Colors.white70),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF06B6D4)) : null,
                ),
              );
            }).toList(),

            // ФОРМА — только если врач выбран
            if (selectedDoctorId != null) ...[
              const SizedBox(height: 24),
              Text("Күнді таңдаңыз", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF06B6D4),
                          onPrimary: Colors.white,
                          surface: Color(0xFF1E293B),
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedDate == null
                      ? "Күн таңдау"
                      : "${selectedDate!.day.toString().padLeft(2,'0')}.${selectedDate!.month.toString().padLeft(2,'0')}.${selectedDate!.year}",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              if (selectedDate != null) ...[
                const SizedBox(height: 20),
                Text("Уақытты таңдаңыз", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: timeSlots.map((time) {
                    final isSelected = selectedTime == time;
                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      selectedColor: const Color(0xFF06B6D4),
                      backgroundColor: const Color(0xFF1E293B),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600),
                      onSelected: (_) => setState(() => selectedTime = time),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: selectedTime == null
                        ? null
                        : () async {
                            final doctorDoc = doctors.firstWhere((d) => d.id == selectedDoctorId);
                            final doctorData = doctorDoc.data() as Map<String, dynamic>;
                            final doctorName = "${doctorData['firstName']} ${doctorData['lastName']}".trim();

                            await _sendRequest(selectedDoctorId!, doctorName);
                          },
                    icon: const Icon(Icons.send, size: 28),
                    label: Text(
                      "Сұраныс жіберу",
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                      shadowColor: const Color(0xFF06B6D4).withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ],
          ],
        );
      },
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
    final patientId = FirebaseAuth.instance.currentUser?.uid;
    if (patientId == null) return const Center(child: Text("Кіру қажет"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: ['pending', 'confirmed']) // Исправлено: whereIn вместо isIn
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("Жазылуларыңыз жоқ", style: GoogleFonts.manrope(fontSize: 18, color: Colors.white70)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

            return Card(
              color: status == 'confirmed' ? Colors.green.withOpacity(0.15) : const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(
                  "${data['doctorName']} • ${data['date']} ${data['time']}",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        status == 'pending' ? Icons.hourglass_bottom : Icons.check_circle,
                        color: status == 'pending' ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status == 'pending' ? "Күтуде..." : "Растау алынды",
                        style: TextStyle(color: status == 'pending' ? Colors.orange : Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

