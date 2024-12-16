/// Returns the image path based on the weather code and optional temperature.
String getWeatherImage(dynamic condition, [double? temperature]) {
  int weatherCode = 0;

  // Safely parse weather code to int
  if (condition is int) {
    weatherCode = condition;
  } else if (condition is String) {
    weatherCode = int.tryParse(condition) ?? 0;
  }

  // Map weather codes to images
  if (weatherCode == 0 || weatherCode == 1) return 'assets/images/Sunny.png'; // Clear sky
  if (weatherCode == 2 || weatherCode == 3) return 'assets/images/Cloudy.png'; // Cloudy
  if (weatherCode >= 45 && weatherCode <= 48) return 'assets/images/Cloudy.png'; // Foggy
  if (weatherCode >= 51 && weatherCode <= 57) return 'assets/images/Rainy.png'; // Drizzle
  if (weatherCode >= 61 && weatherCode <= 67) return 'assets/images/Rainy.png'; // Rain
  if (weatherCode >= 71 && weatherCode <= 85) return 'assets/images/Snowy.png'; // Snowfall

  // Adjust for cold temperatures for HomeScreen logic
  if (temperature != null && temperature < 0) return 'assets/images/Snowy.png';

  // Default fallback
  return 'assets/images/Cloudy.png';
}

/// Returns weather recommendations based on the condition.
String getWeatherRecommendation(dynamic condition) {
  int weatherCode = 0;

  // Safely parse weather code to int
  if (condition is int) {
    weatherCode = condition;
  } else if (condition is String) {
    weatherCode = int.tryParse(condition) ?? 0;
  }

  // Recommendations based on weather codes
  if (weatherCode == 0 || weatherCode == 1) {
    return "Clear skies today, enjoy the beautiful weather ☀️";
  } else if (weatherCode == 2 || weatherCode == 3) {
    return "Partly cloudy skies, a pleasant day ahead ☁️";
  } else if (weatherCode >= 45 && weatherCode <= 48) {
    return "Foggy conditions, drive carefully 🌫️";
  } else if (weatherCode >= 51 && weatherCode <= 57) {
    return "Light drizzle ahead, carry an umbrella ☂️";
  } else if (weatherCode >= 61 && weatherCode <= 67) {
    return "Rainy weather expected, stay dry 🌧️";
  } else if (weatherCode >= 71 && weatherCode <= 85) {
    return "Snowfall incoming, dress warmly ❄️";
  }

  // Default recommendation
  return "Stay prepared for any weather!";
}

/// Returns mood theme name based on the weather code.
String getWeatherMoodFromCode(dynamic condition) {
  int weatherCode = 0;

  // Safely parse weather code to int
  if (condition is int) {
    weatherCode = condition;
  } else if (condition is String) {
    weatherCode = int.tryParse(condition) ?? 0;
  }

  // Return mood theme based on weather code
  if (weatherCode == 0 || weatherCode == 1) return 'sunny'; // Clear sky
  if (weatherCode == 2 || weatherCode == 3) return 'cloudy'; // Cloudy
  if (weatherCode >= 51 && weatherCode <= 67) return 'rainy'; // Rainy
  if (weatherCode >= 71 && weatherCode <= 85) return 'snowy'; // Snowy

  return 'default'; // Default fallback theme
}
