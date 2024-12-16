import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool _isDarkMode = false;
  String _temperatureUnit = "Celsius";
  String _currentBackground = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;
  String get temperatureUnit => _temperatureUnit;
  String get currentBackground => _currentBackground;

  // Set mood-based theme dynamically
  void setMoodTheme(String mood) {
    switch (mood) {
      case 'sunny':
        _themeData = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.yellow[100],
        );
        break;
      case 'rainy':
        _themeData = ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.blue[900],
        );
        break;
      case 'cloudy':
        _themeData = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.grey[300],
        );
        break;
      case 'snowy':
        _themeData = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.blue[50],
        );
        break;
      default:
        _themeData = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    }
    notifyListeners();
    savePreferencesToFirestore();
  }

  // Toggle theme between light and dark
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
    await savePreferencesToFirestore();
  }

  // Toggle temperature unit between Celsius and Fahrenheit
  Future<void> toggleTemperatureUnit() async {
    _temperatureUnit = _temperatureUnit == "Celsius" ? "Fahrenheit" : "Celsius";
    notifyListeners();
    await savePreferencesToFirestore();
  }

  // Set custom background
  Future<void> setCustomBackground(String path) async {
    _currentBackground = path;
    notifyListeners();
    await savePreferencesToFirestore();
  }

  // Reset custom background
  Future<void> resetBackground() async {
    _currentBackground = "";
    notifyListeners();
    await savePreferencesToFirestore();
  }

  // Reset all custom alerts
  void resetAllCustomAlerts() {
    notifyListeners();
  }

  // Save preferences to Firestore
  Future<void> savePreferencesToFirestore() async {
    await _firestore.collection('preferences').doc('exampleUser123').set({
      'isDarkMode': _isDarkMode,
      'temperatureUnit': _temperatureUnit,
      'currentBackground': _currentBackground,
    }, SetOptions(merge: true));
  }

  // Load preferences from Firestore
  Future<void> loadPreferencesFromFirestore() async {
    try {
      final doc =
          await _firestore.collection('preferences').doc('exampleUser123').get();
      final data = doc.data();
      if (data != null) {
        _isDarkMode = data['isDarkMode'] ?? false;
        _temperatureUnit = data['temperatureUnit'] ?? "Celsius";
        _currentBackground = data['currentBackground'] ?? "";
        _themeData = _isDarkMode ? ThemeData.dark() : ThemeData.light();
        notifyListeners();
      }
    } catch (e) {
      print("Error loading preferences: $e");
    }
  }
}
