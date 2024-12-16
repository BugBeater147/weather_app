import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';
import '../weather_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? weatherData;
  List<String> citySuggestions = [];
  bool isLoading = false;
  bool isOffline = false;

  String city = "Atlanta"; // Default city
  final TextEditingController _cityController = TextEditingController();
  String currentBackground = "assets/images/Cloudy.png"; // Default background

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  /// Fetch weather data and apply mood-based theme
  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
      isOffline = false;
    });

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final weatherService = WeatherService();
      final currentWeather = await weatherService.fetchCurrentWeatherByCity(
        city,
        themeProvider.temperatureUnit,
      );

      setState(() {
        weatherData = {
          'temp': currentWeather['temperature'] ?? 'N/A',
          'windspeed': currentWeather['windspeed'] ?? 'N/A',
          'condition': currentWeather['condition'] ?? 'unknown',
        };
        citySuggestions.clear();
      });

      // Determine the mood theme based on weather condition and temperature
      int weatherCode = int.tryParse(currentWeather['condition']) ?? 0;
      double temperature =
          double.tryParse(currentWeather['temperature'].toString()) ?? 0.0;

      // Fetch the appropriate background image
      setState(() {
        currentBackground = getWeatherImage(weatherCode, temperature);
      });

      // Apply mood-based theme
      String mood = getWeatherMoodFromCode(weatherCode);
      themeProvider.setMoodTheme(mood);

      // Trigger notifications based on condition
      if (weatherCode >= 200 && weatherCode <= 531) {
        await NotificationService.showNotification(
          title: "Weather Alert",
          body: "Rain expected today in $city! 🌧️",
        );
      } else if (weatherCode >= 600 && weatherCode <= 622) {
        await NotificationService.showNotification(
          title: "Weather Alert",
          body: "Snowfall expected today in $city! ❄️",
        );
      }
    } catch (e) {
      await loadCachedWeather();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Load cached weather data when offline
  Future<void> loadCachedWeather() async {
    setState(() => isOffline = true);

    final weatherService = WeatherService();
    final cachedData =
        await weatherService.loadCachedWeatherData('current_weather');

    if (cachedData != null) {
      setState(() {
        weatherData = {
          'temp': cachedData['temperature'] ?? 'N/A',
          'windspeed': cachedData['windspeed'] ?? 'N/A',
          'condition': cachedData['weathercode'] ?? 'unknown',
        };
      });
    }
  }

  /// Fetch dynamic city suggestions
  Future<void> fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => citySuggestions.clear());
      return;
    }

    final weatherService = WeatherService();
    final suggestions = await weatherService.fetchCitySuggestions(query);
    setState(() => citySuggestions = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weatherly App"),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-Screen Background Image
          Positioned.fill(
            child: Image.asset(
              currentBackground,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Field with Suggestions
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: "Enter city name",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() => city = _cityController.text);
                        fetchWeather();
                      },
                    ),
                  ),
                  onChanged: fetchCitySuggestions,
                ),
                if (citySuggestions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: citySuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(citySuggestions[index]),
                          onTap: () {
                            setState(() {
                              city = citySuggestions[index];
                              _cityController.text = citySuggestions[index];
                              citySuggestions.clear();
                            });
                            fetchWeather();
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                // Weather Data
                if (isLoading)
                  const CircularProgressIndicator()
                else if (weatherData == null)
                  const Text(
                    "No weather data available.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                else
                  Column(
                    children: [
                      // Removed the extra image here
                      Text(
                        "Temperature: ${weatherData!['temp']}°${themeProvider.temperatureUnit}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Wind Speed: ${weatherData!['windspeed']} km/h",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Buttons
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/forecast',
                            arguments: {'city': city}),
                        child: const Text("View 7-Day Forecast"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/hourly',
                            arguments: {'city': city}),
                        child: const Text("View Hourly Forecast"),
                      ),
                      ElevatedButton(
                        onPressed: fetchWeather,
                        child: const Text("Refresh Weather"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/map'),
                        child: const Text("Open Map"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/backgroundSelection'),
                        child: const Text("Change Background"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/community'),
                        child: const Text("Community Insights"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
