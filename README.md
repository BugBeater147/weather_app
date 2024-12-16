Youtube link:
-> Presentation: https://www.youtube.com/watch?v=a4x5KA7a-4Q 
-> Demo: https://www.youtube.com/watch?v=eIxWPjJ_66c
Weather App 🌦️
This Weather App allows users to view current weather, 7-day forecasts, hourly forecasts, and explore weather-related features like maps and community reports. The app integrates Firebase, Google Maps Platform, and Open-Meteo API.

Features:
Current Weather: View the current temperature, wind speed, and weather condition.
7-Day Forecast: See the weather forecast for the next 7 days.
Hourly Forecast: View the weather forecast on an hourly basis.
Interactive Map: Select locations on the map to view weather information.
Customizable Backgrounds: Users can upload custom backgrounds.
Notifications: Get weather alerts using Firebase Cloud Messaging.
Community Insights: Share and view weather reports submitted by the community.
Prerequisites:
Ensure the following tools and software are installed:

Flutter SDK
Install Flutter from Flutter's official website.

Android Studio or VS Code (Recommended IDEs).
Install Flutter and Dart plugins in your IDE.

Firebase Setup

Create a Firebase project at Firebase Console.
Add an Android or iOS app in your Firebase project.
Download the google-services.json (Android) or GoogleService-Info.plist (iOS) file and place it in the appropriate project directory.
Google Maps API Key

Enable the Maps SDK from the Google Cloud Console.
Add your API key in the project.
Installation and Running Locally 
Follow these steps to run the app on your device:

1. Clone the Repository
Open your terminal and run:

bash
Copy code
git clone https://github.com/BugBeater147/weather_app.git
cd weather_app
2. Install Dependencies
Run the following command to get all required packages:

bash
Copy code
flutter pub get
3. Configure Firebase
Place your google-services.json file in:
android/app/
If on iOS, place the GoogleService-Info.plist file in:
ios/Runner/
4. Add Google Maps API Key
Open android/app/src/main/AndroidManifest.xml and add:

xml
Copy code
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
For iOS, add the key in ios/Runner/AppDelegate.swift:

swift
Copy code
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
5. Run the App
Start the app with the following command:

bash
Copy code
flutter run
Make sure a simulator/emulator or physical device is connected.

Usage:
Home Screen

Enter a city name to fetch the current weather.
View temperature, wind speed, and weather conditions.
7-Day Forecast

Tap "View 7-Day Forecast" to see the weather forecast for the week.
Hourly Forecast

Tap "View Hourly Forecast" to view hourly temperature changes.
Interactive Map

Tap "Open Map" and select a location to see its weather information.
Change Background

Go to "Change Background" and upload a custom background or select from existing ones.
Community Reports

Share weather reports with a description and images under "Community Insights."
Notifications

Receive weather alerts via Firebase notifications.
Screenshots
Home Screen	7-Day Forecast	Hourly Forecast
Technologies Used:
Flutter: Cross-platform app development.
Firebase: Authentication, Firestore, and Cloud Messaging.
Google Maps Platform: Interactive map integration.
Open-Meteo API: Weather data.
Contributors:
BugBeater147
