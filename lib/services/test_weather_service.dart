import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = "b451535897c484d35e8e8db4dcde35c3";

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "temperature": data["main"]["temp"],
        "description": data["weather"][0]["description"]
      };
    } else {
      throw Exception("Failed to fetch weather data");
    }
  }
}

void main() async {
  final weatherService = WeatherService();

  try {
    final data = await weatherService.fetchCurrentWeather("London");
    print("Weather Data:");
    print("Temperature: ${data['temperature']}°C");
    print("Condition: ${data['description']}");
  } catch (e) {
    print("Error: $e");
  }
}
