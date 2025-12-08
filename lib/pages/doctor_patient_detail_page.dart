// lib/pages/doctor_patient_detail_page.dart — ФИНАЛЬНАЯ РАБОЧАЯ ВЕРСИЯ (ДЕКАБРЬ 2025)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medkenes/services/voice_to_smartdoc_service.dart';

class DoctorPatientDetailPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const DoctorPatientDetailPage({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<DoctorPatientDetailPage> createState() => _DoctorPatientDetailPageState();
}

class _DoctorPatientDetailPageState extends State<DoctorPatientDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.patientData['fullName'] ?? 'Белгісіз пациент';
    final String phone = widget.patientData['phone'] ?? '—';
    final String birthDate = widget.patientData['birthDate'] ?? '—';
    final String gender = widget.patientData['gender'] == 'male' ? 'Ер' : 'Әйел';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Пациент картасы",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Карточка пациента
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF06B6D4),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name,
                        style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text("$gender • $birthDate",
                        style: GoogleFonts.manrope(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(phone,
                        style: GoogleFonts.manrope(fontSize: 18, color: const Color(0xFF06B6D4))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ГЛАВНОЕ: ЗАЖАЛ → ГОВОРИШЬ → ОТПУСТИЛ → СРАЗУ SmartDoc
            GestureDetector(
              onTapDown: (_) async {
                setState(() => _isRecording = true);
                final started = await VoiceToSmartDocService.startRecordingAndWaitForRelease(
                  context: context,
                  patientId: widget.patientId,
                  patientName: name,
                );
                if (!started && context.mounted) {
                  setState(() => _isRecording = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Микрофон рұқсаты жоқ"), backgroundColor: Colors.red),
                  );
                }
              },
              onTapUp: (_) async {
                if (_isRecording) {
                  setState(() => _isRecording = false);
                  await VoiceToSmartDocService.stopRecordingAndProcess(
                    context: context,
                    patientId: widget.patientId,
                    patientName: name,
                    patientData: widget.patientData, // ← ВОТ ОНО — ПЕРЕДАЁМ ДАННЫЕ!
                  );
                }
              },
              onTapCancel: () async {
                if (_isRecording) {
                  setState(() => _isRecording = false);
                  await VoiceToSmartDocService.stopRecordingAndProcess(
                    context: context,
                    patientId: widget.patientId,
                    patientName: name,
                    patientData: widget.patientData,
                  );
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isRecording) ...[
                        for (int i = 0; i < 3; i++)
                          Transform.scale(
                            scale: 0.8 + (_pulseAnimation.value + i * 0.2),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF06B6D4).withOpacity(0.15 - i * 0.05),
                              ),
                            ),
                          ),
                      ],
                      Transform.scale(
                        scale: _isRecording ? _scaleAnimation.value : 1.0,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06B6D4).withOpacity(0.7),
                                blurRadius: 30,
                                spreadRadius: _isRecording ? 15 : 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Text(
              _isRecording ? "Сөйлеп жатырсыз... Босатыңыз" : "Басып тұрып сөйлеңіз",
              style: GoogleFonts.manrope(fontSize: 17, color: Colors.white70),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),
            Text("Алдыңғы қабылдаулар",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('smartdocs')
                    .where('patientId', isEqualTo: widget.patientId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Әзірге құжаттар жоқ", style: GoogleFonts.manrope(color: Colors.white54)));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                      final date = (data['createdAt'] as Timestamp).toDate();
                      return Card(
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.description, color: Color(0xFF06B6D4)),
                          title: Text("SmartDoc • ${date.day}.${date.month}.${date.year}"),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("SmartDoc ашылады...")),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}