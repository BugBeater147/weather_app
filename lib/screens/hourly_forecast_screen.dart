import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../weather_utils.dart'; // Import weather_utils to access getWeatherImage

class HourlyForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String city;
  final String unit;

  const HourlyForecastScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.unit,
  }) : super(key: key);

  @override
  State<HourlyForecastScreen> createState() => _HourlyForecastScreenState();
}

class _HourlyForecastScreenState extends State<HourlyForecastScreen> {
  late Future<List<dynamic>> hourlyForecastData;

  @override
  void initState() {
    super.initState();
    hourlyForecastData = WeatherService().fetchHourlyForecast(
      widget.latitude,
      widget.longitude,
      widget.unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hourly Forecast - ${widget.city}"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: hourlyForecastData,
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
                final hour = forecast[index];
                final int weatherCode = int.tryParse(hour['condition']) ?? 0;

                return ListTile(
                  leading: Image.asset(getWeatherImage(weatherCode)), // Fixed
                  title: Text("Time: ${hour['time']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Temperature: ${hour['temperature']}°${widget.unit == 'Celsius' ? 'C' : 'F'}",
                      ),
                      Text(
                        getWeatherRecommendation(weatherCode),
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No hourly data available."));
          }
        },
      ),
    );
  }
}

