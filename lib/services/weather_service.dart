import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Save weather data to cache
  Future<void> saveWeatherToCache(
      String key, Map<String, dynamic> weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(weatherData);
    await prefs.setString(key, jsonData);
  }

  /// Load cached weather data
  Future<Map<String, dynamic>?> loadCachedWeatherData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(key);
    if (cachedData != null) {
      return json.decode(cachedData);
    }
    return null;
  }

  /// Fetch city suggestions
  Future<List<String>> fetchCitySuggestions(String query) async {
    final geocodeUrl = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json',
    );

    final response = await http.get(geocodeUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results']
              ?.map<String>((city) => city['name'] as String)
              ?.toList() ??
          [];
    }
    return [];
  }

  /// Fetch current weather data for latitude and longitude
  Future<Map<String, dynamic>> fetchCurrentWeather(
      double latitude, double longitude, String unit) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=${unit.toLowerCase()}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['current_weather'];
      // Cache weather data
      await saveWeatherToCache('current_weather', data);
      return data;
    } else {
      throw Exception("Failed to fetch current weather");
    }
  }

  /// Fetch current weather data by city name
  Future<Map<String, dynamic>> fetchCurrentWeatherByCity(
      String city, String unit) async {
    final locationUrl = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=en&format=json',
    );

    final locationResponse = await http.get(locationUrl);

    if (locationResponse.statusCode == 200) {
      final locationData = json.decode(locationResponse.body);
      if (locationData['results'] != null &&
          locationData['results'].isNotEmpty) {
        final double latitude = locationData['results'][0]['latitude'];
        final double longitude = locationData['results'][0]['longitude'];

        // Fetch current weather using latitude and longitude
        return await fetchCurrentWeather(latitude, longitude, unit);
      } else {
        throw Exception("City not found");
      }
    } else {
      throw Exception("Failed to fetch location data for city: $city");
    }
  }

  /// Fetch 7-day weather forecast for latitude and longitude
  Future<List<dynamic>> fetch7DayForecast(
      double latitude, double longitude, String unit) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,weathercode&temperature_unit=${unit.toLowerCase()}&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final daily = data['daily'];
      // Cache forecast data
      await saveWeatherToCache('7day_forecast', daily);
      return List.generate(7, (index) {
        return {
          "date": daily['time'][index].toString(),
          "temp_max": daily['temperature_2m_max'][index].toString(),
          "temp_min": daily['temperature_2m_min'][index].toString(),
          "condition": daily['weathercode'][index].toString(),
        };
      });
    } else {
      throw Exception("Failed to fetch 7-day forecast");
    }
  }

  /// Fetch hourly weather forecast for latitude and longitude
  Future<List<dynamic>> fetchHourlyForecast(
      double latitude, double longitude, String unit) async {
    final url = Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weathercode&temperature_unit=${unit.toLowerCase()}&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hourly = data['hourly'];
      // Cache hourly data
      await saveWeatherToCache('hourly_forecast', hourly);
      return List.generate(hourly['time'].length, (index) {
        return {
          "time": hourly['time'][index].toString(),
          "temperature": hourly['temperature_2m'][index].toString(),
          "condition": hourly['weathercode'][index].toString(),
        };
      });
    } else {
      throw Exception("Failed to fetch hourly forecast");
    }
  }
}
