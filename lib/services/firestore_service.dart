import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save Theme Preference
  Future<void> saveThemePreference(String userId, bool isDarkMode) async {
    await _firestore.collection('users').doc(userId).set({
      'isDarkMode': isDarkMode,
    }, SetOptions(merge: true));
  }

  /// Get Theme Preference
  Future<bool> getThemePreference(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data()?['isDarkMode'] ?? false;
  }

  /// Save Custom Alert Preference
  Future<void> saveCustomAlerts(String userId, Map<String, dynamic> alerts) async {
    await _firestore.collection('users').doc(userId).set({
      'customAlerts': alerts,
    }, SetOptions(merge: true));
  }

  /// Get Custom Alert Preference
  Future<Map<String, dynamic>> getCustomAlerts(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data()?['customAlerts'] ?? {};
  }
}
