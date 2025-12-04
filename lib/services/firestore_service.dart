import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Получить роль пользователя
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'patient';
    } catch (e) {
      return 'patient';
    }
  }

  // Стрим роли (для RoleRouter)
  Stream<String> userRoleStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      return doc.data()?['role'] ?? 'patient';
    });
  }

  // Пример: получить визиты пользователя
  Stream<QuerySnapshot> getAppointments(String uid) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();
  }
}