import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/hourly_forecast_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/background_selection_screen.dart';
import 'screens/community_screen.dart'; // Import CommunityInsightsScreen
import 'screens/splash_screen.dart'; // Import Splash Screen
import 'services/notification_service.dart';
import 'services/firestore_service.dart';

// Background Message Handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📨 Background Notification: ${message.notification?.title}");
  NotificationService.showNotification(
    title: message.notification?.title ?? "New Notification",
    body: message.notification?.body ?? "You have a new message!",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await NotificationService.initialize(); // Initialize local notifications

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FCM Setup
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Retrieve and print the FCM token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Handle messages when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message received while app is in foreground: ${message.messageId}");
    NotificationService.showNotification(
      title: message.notification?.title ?? "New Notification",
      body: message.notification?.body ?? "You have a new message!",
    );
  });

  // Firestore Integration: Load Preferences before starting the app
  final ThemeProvider themeProvider = ThemeProvider();
  try {
    await themeProvider.loadPreferencesFromFirestore();
  } catch (e) {
    print("Error loading preferences: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/splash', // Add Splash Screen as the first route
      routes: {
        '/splash': (context) =>
            const SplashScreen(), // Added splash screen route
        '/': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/forecast': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>;

          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          return ForecastScreen(
            latitude: arguments['latitude'] ?? 0.0,
            longitude: arguments['longitude'] ?? 0.0,
            city: arguments['city'] ?? "Unknown",
            unit: themeProvider.temperatureUnit,
          );
        },
        '/hourly': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>;

          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          return HourlyForecastScreen(
            latitude: arguments['latitude'] ?? 0.0,
            longitude: arguments['longitude'] ?? 0.0,
            city: arguments['city'] ?? "Unknown",
            unit: themeProvider.temperatureUnit,
          );
        },
        '/settings': (context) => const SettingsScreen(),
        '/backgroundSelection': (context) => BackgroundSelectionScreen(),
        '/community': (context) => const CommunityInsightsScreen(),
      },
    );
  }
}
