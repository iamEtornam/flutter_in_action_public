import 'package:flutter/material.dart';
import 'package:weather_app/models/src/weather.dart';

/// The hourly data is based on 3 hour intervals from 0..24
List<int> hours = [3, 6, 9, 12, 15, 18, 21, 24];

Map<WeatherDescription, IconData> weatherIcons = {
  WeatherDescription.sunny: Icons.wb_sunny,
  WeatherDescription.cloudy: Icons.wb_cloudy,
  WeatherDescription.clear: Icons.brightness_2,
  WeatherDescription.rain: Icons.beach_access,
};

Map<TemperatureUnit, String> temperatureLabels = {
  TemperatureUnit.celsius: "°C",
  TemperatureUnit.fahrenheit: "°F",
};