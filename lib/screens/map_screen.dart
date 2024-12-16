import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? selectedLocation;
  String weatherInfo = "Tap a location to view weather";

  // Function to fetch weather data from Open-Meteo API
  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude, String temperatureUnit) async {
    final unit = temperatureUnit == 'Celsius' ? 'celsius' : 'fahrenheit';
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=$unit');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['current_weather'];
    } else {
      throw Exception("Failed to fetch weather data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Map with Open-Meteo"),
      ),
      body: Stack(
        children: [
          // Google Map Widget
          GoogleMap(
            onTap: (LatLng location) async {
              setState(() {
                weatherInfo = "Fetching weather...";
              });
              try {
                final weatherData = await fetchWeather(
                  location.latitude,
                  location.longitude,
                  themeProvider.temperatureUnit,
                );
                setState(() {
                  selectedLocation = location;
                  weatherInfo =
                      "Temperature: ${weatherData['temperature']}°${themeProvider.temperatureUnit == 'Celsius' ? 'C' : 'F'}\n"
                      "Wind Speed: ${weatherData['windspeed']} km/h\n"
                      "Weather Code: ${weatherData['weathercode']}";
                });
              } catch (e) {
                setState(() {
                  weatherInfo = "Error: $e";
                });
              }
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.749, -84.388), // Default location: Atlanta
              zoom: 10,
            ),
          ),
          // Weather Information Display
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                weatherInfo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
