import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _alertController = TextEditingController();
  Map<String, bool> _customAlerts = {}; // Ensure boolean for all alert values.

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _loadPreferencesSafely();
  }

  /// Load custom alerts safely
  Future<void> _loadAlerts() async {
    try {
      final alerts = await _firestoreService.getCustomAlerts("exampleUser123");
      setState(() {
        _customAlerts = alerts.map((key, value) {
          return MapEntry(key, value is bool ? value : false);
        });
      });
    } catch (e) {
      print("Error loading alerts: $e");
    }
  }

  /// Load ThemeProvider preferences
  Future<void> _loadPreferencesSafely() async {
    try {
      await Provider.of<ThemeProvider>(context, listen: false)
          .loadPreferencesFromFirestore();
    } catch (e) {
      print("Error loading preferences: $e");
    }
  }

  /// Save a new custom alert
  Future<void> _saveAlert(String condition) async {
    if (condition.isEmpty) return;

    try {
      setState(() {
        _customAlerts[condition] = true;
      });
      await _firestoreService.saveCustomAlerts("exampleUser123", _customAlerts);
      _alertController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alert saved successfully!")),
      );
    } catch (e) {
      print("Error saving alert: $e");
    }
  }

  /// Toggle alert value
  Future<void> _toggleAlert(String condition, bool value) async {
    try {
      setState(() {
        _customAlerts[condition] = value;
      });
      await _firestoreService.saveCustomAlerts("exampleUser123", _customAlerts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Alert for $condition updated!")),
      );
    } catch (e) {
      print("Error toggling alert: $e");
    }
  }

  /// Reset all custom alerts
  Future<void> _resetAllAlerts() async {
    try {
      setState(() {
        _customAlerts.clear();
      });
      await _firestoreService.saveCustomAlerts("exampleUser123", {});
      Provider.of<ThemeProvider>(context, listen: false).resetAllCustomAlerts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All alerts have been reset!")),
      );
    } catch (e) {
      print("Error resetting alerts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (value) async {
                await themeProvider.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      themeProvider.isDarkMode
                          ? "Dark Mode Enabled"
                          : "Light Mode Enabled",
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            // Temperature Unit Toggle
            ListTile(
              title: const Text("Temperature Unit"),
              subtitle: Text("Current: ${themeProvider.temperatureUnit}"),
              trailing: ElevatedButton(
                onPressed: () async {
                  await themeProvider.toggleTemperatureUnit();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Temperature Unit set to ${themeProvider.temperatureUnit}"),
                    ),
                  );
                },
                child: const Text("Toggle Unit"),
              ),
            ),
            const Divider(),

            // Reset All Custom Alerts
            ListTile(
              title: const Text("Reset All Custom Alerts"),
              subtitle:
                  const Text("Remove all saved weather condition alerts."),
              trailing: ElevatedButton(
                onPressed: _resetAllAlerts,
                child: const Text("Reset"),
              ),
            ),
            const Divider(),

            // Custom Weather Alerts Header
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Custom Weather Alerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // TextField for Adding New Alerts
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _alertController,
                decoration: InputDecoration(
                  labelText: "Enter weather condition (e.g., Rain)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (_alertController.text.isNotEmpty) {
                        _saveAlert(_alertController.text.trim());
                      }
                    },
                  ),
                ),
              ),
            ),

            // List of Custom Alerts with Switch
            Column(
              children: _customAlerts.keys.map((key) {
                return SwitchListTile(
                  title: Text("Alert for: $key"),
                  value: _customAlerts[key] ?? false,
                  onChanged: (value) {
                    _toggleAlert(key, value);
                  },
                  secondary: const Icon(Icons.notifications_active),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
