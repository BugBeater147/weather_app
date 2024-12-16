import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else {
      print('User denied notification permissions');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _firestore
        .collection('preferences')
        .doc('user_prefs')
        .set(preferences);
  }

  Future<Map<String, dynamic>> fetchUserPreferences() async {
    final doc =
        await _firestore.collection('preferences').doc('user_prefs').get();
    return doc.data() ?? {};
  }
}
