// lib/pages/personal_info_page.dart — ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Теперь контроллеры — единственный источник правды
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _iinController;
  late TextEditingController _addressController;
  late TextEditingController _bloodTypeController;
  DateTime? _birthDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _iinController = TextEditingController();
    _addressController = TextEditingController();
    _bloodTypeController = TextEditingController();

    _loadPatientData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _iinController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('patients').doc(userId).get();
    final data = doc.data() ?? {};

    setState(() {
      _fullNameController.text = data['fullName'] ?? '';
      _phoneController.text = data['phone'] ?? FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
      _iinController.text = data['iin'] ?? '';
      _addressController.text = data['address'] ?? '';
      _bloodTypeController.text = data['bloodType'] ?? '';
      _birthDate = (data['birthDate'] as Timestamp?)?.toDate();
      _isLoading = false;
    });
  }

  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('patients').doc(userId).set({
      'fullName': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'iin': _iinController.text.trim(),
      'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
      'address': _addressController.text.trim(),
      'bloodType': _bloodTypeController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Мәліметтер сақталды!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Жеке мәліметтер", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("ФИО (толық аты-жөні)", _fullNameController, validator: (v) => v!.isEmpty ? "Толтырыңыз" : null),
              const SizedBox(height: 16),
              _buildTextField("Телефон", _phoneController, validator: (v) => v!.isEmpty ? "Толтырыңыз" : null, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField("ИИН (12 цифр)", _iinController, validator: (v) => v!.length != 12 ? "12 цифр болуы керек" : null, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTextField("Мекенжай", _addressController),
              const SizedBox(height: 16),
              _buildTextField("Қан тобы (мысалы: A(II) Rh+)", _bloodTypeController),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _savePatientData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Сақтау", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      style: GoogleFonts.inter(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Туған күні",
          labelStyle: GoogleFonts.inter(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate != null ? DateFormat('dd.MM.yyyy').format(_birthDate!) : "Таңдаңыз",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}