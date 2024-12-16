import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../weather_utils.dart'; // Import weather_utils to access getWeatherImage

class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String city;
  final String unit;

  const ForecastScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.unit,
  }) : super(key: key);

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<List<dynamic>> forecastData;

  @override
  void initState() {
    super.initState();
    forecastData = WeatherService().fetch7DayForecast(
      widget.latitude,
      widget.longitude,
      widget.unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("7-Day Forecast - ${widget.city}"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: forecastData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final forecast = snapshot.data!;
            return ListView.builder(
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                final day = forecast[index];
                final int weatherCode = int.tryParse(day['condition']) ?? 0;

                return ListTile(
                  leading: Image.asset(getWeatherImage(weatherCode)), // Fixed
                  title: Text("Date: ${day['date']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Max: ${day['temp_max']}°${widget.unit == 'Celsius' ? 'C' : 'F'}, "
                        "Min: ${day['temp_min']}°${widget.unit == 'Celsius' ? 'C' : 'F'}",
                      ),
                      const SizedBox(height: 5),
                      Text(
                        getWeatherRecommendation(weatherCode),
                        style: const TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No forecast data available."));
          }
        },
      ),
    );
  }
}
