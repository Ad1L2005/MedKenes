// lib/RegisterPage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'patient';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showSnackBar('Барлық өрістерді толтырыңыз', false);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('Құпия сөздер сәйкес келмейді', false);
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Құпия сөз кемінде 6 таңбадан тұруы керек', false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      final fullName = "$firstName $lastName";

      await user.updateDisplayName(fullName);
      await user.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': fullName,
        'email': email,
        'role': _selectedRole,
        'registeredAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        _showSnackBar('Сәтті тіркелдіңіз! Email-ді растаңыз', true);
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Қате орын алды';
      switch (e.code) {
        case 'email-already-in-use': message = 'Бұл email арқылы тіркелгі бар'; break;
        case 'weak-password': message = 'Құпия сөз тым әлсіз'; break;
        case 'invalid-email': message = 'Email форматы қате'; break;
      }
      _showSnackBar(message, false);
    } catch (e) {
      _showSnackBar('Белгісіз қате', false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.manrope(color: Colors.white)),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Тіркелу", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text("Жаңа аккаунт құру", style: GoogleFonts.manrope(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 40),

              _buildField(_firstNameController, "Аты", Icons.person_outline),
              const SizedBox(height: 16),
              _buildField(_lastNameController, "Тегі", Icons.person),
              const SizedBox(height: 16),
              _buildField(_emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField(_passwordController, "Құпия сөз", Icons.lock_outline, obscure: true),
              const SizedBox(height: 16),
              _buildField(_confirmPasswordController, "Қайталаңыз", Icons.lock_outline, obscure: true),

              const SizedBox(height: 50),

              Text("Сіз кімсіз?", style: GoogleFonts.inter(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
const SizedBox(height: 30),

LayoutBuilder(
  builder: (context, constraints) {
    final double cardWidth = (constraints.maxWidth - 40) / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _roleCardModern(
          role: "patient",
          title: "Мен\nпациентпін",
          icon: Icons.person_outline,
          color: const Color(0xFF06B6D4),
          selectedColor: const Color(0xFF06B6D4),
          width: cardWidth,
        ),
        _roleCardModern(
          role: "doctor",
          title: "Мен\nдәрігермін",
          icon: Icons.local_hospital_outlined,
          color: Colors.cyan,
          selectedColor: Colors.cyan,
          width: cardWidth,
        ),
        _roleCardModern(
          role: "ambulance",
          title: "Мен жедел\nжәрдеммін",
          icon: Icons.emergency,
          color: Colors.cyan,
          selectedColor: Colors.cyan,
          width: cardWidth,
        ),
      ],
    );
  },
),

const SizedBox(height: 70),

              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.5), blurRadius: 20)],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _isLoading ? null : _register,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : Text("ТІРКЕЛУ", style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Кіру бетіне оралу", style: GoogleFonts.manrope(color: const Color(0xFF06B6D4), fontWeight: FontWeight.w600))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType, bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  // ← КРАСИВАЯ КАРТОЧКА С ПОЛОСАМИ ←
  Widget _roleCardModern({
  required String role,
  required String title,
  required IconData icon,
  required Color color,
  required Color selectedColor,
  required double width,
}) {
  final bool selected = _selectedRole == role;

  return GestureDetector(
    onTap: () => setState(() => _selectedRole = role),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: width,
      height: 135,
      decoration: BoxDecoration(
        color: selected ? selectedColor.withOpacity(0.2) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selected ? selectedColor : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? selectedColor.withOpacity(0.5) : Colors.black38,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 46,
            color: selected ? Colors.white : color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    ),
  );
}
  }


// ← ЭТОТ КЛАСС ДОЛЖЕН БЫТЬ ВНЕ _RegisterPageState, НО В ТОМ ЖЕ ФАЙЛЕ! ←
class DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final yellow = Paint()..color = Colors.amber;
    final black = Paint()..color = Colors.black87;

    const stripeWidth = 28.0;
    double offset = -size.height;

    while (offset < size.height * 2) {
      final path = Path()
        ..moveTo(0, offset)
        ..lineTo(size.width, offset + size.width * 0.7)
        ..lineTo(size.width, offset + stripeWidth + size.width * 0.7)
        ..lineTo(0, offset + stripeWidth)
        ..close();

      canvas.drawPath(path, ((offset / stripeWidth) % 2).abs() < 0.5 ? yellow : black);
      offset += stripeWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}