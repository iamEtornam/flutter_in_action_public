import 'package:weather_app/models/src/weather.dart';

List<String> allCities = [
  "Portland",
  "Berlin",
  "Buenos Aires",
  "Chaing Mai",
  "Eugene",
  "Georgetown",
  "London",
  "New York",
  "Panama City",
  "San Francisco",
  "Tokyo",
  "Tuscon",
];

class AppSettings {
  TemperatureUnit selectedTemperature = TemperatureUnit.celsius;
  Map<String, bool> selectedCities = {};
  String selectedCity = allCities[0];

  AppSettings() {
    allCities.forEach(
            (String city) => selectedCities.putIfAbsent(city, () => false));
    selectedCities["Portland"] = true;
    selectedCities["London"] = true;
  }
}
