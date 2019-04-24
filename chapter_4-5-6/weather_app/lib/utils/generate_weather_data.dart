import 'dart:math' as math;

import 'package:weather_app/models/src/app_settings.dart' as settings;
import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/models/src/weather.dart';

// Used to fake data.
class WeatherDataHelper {
  DateTime _today = new DateTime.now().toUtc();
  DateTime startDateTime;
  DateTime dailyDate;
  var _random = new math.Random();
  List<City> cities = settings.allAddedCities;

  WeatherDataHelper() {
    startDateTime = new DateTime.utc(_today.year, _today.month, _today.day, 0);
    dailyDate = _today;
  }

  int generateCloudCoverageNum(WeatherDescription description) {
    switch (description) {
      case WeatherDescription.cloudy:
        return 75;
      case WeatherDescription.rain:
        return 45;
      case WeatherDescription.clear:
      case WeatherDescription.sunny:
      default:
        return 5;
    }
  }

  WeatherDescription generateTimeAwareWeatherDescription(DateTime time) {
    var hour = time.hour;

    var descriptions = WeatherDescription.values;
    var description =
        descriptions.elementAt(_random.nextInt(descriptions.length));
    if (hour < 6 || hour > 18) {
      if (description == WeatherDescription.sunny) {
        description = WeatherDescription.clear;
      }
    } else {
      if (description == WeatherDescription.clear) {
        description = WeatherDescription.sunny;
      }
    }
    return description;
  }

  ForecastDay dailyForecastGenerator(City city, int low, int high) {
    List<Weather> forecasts = [];
    int runningMin = 555;
    int runningMax = -555;

    for (var i = 0; i < 8; i++) {
      startDateTime = startDateTime.add(new Duration(hours: 3));
      int temp = _random.nextInt(high);
      WeatherDescription randomDescription =
          generateTimeAwareWeatherDescription(startDateTime);

      var tempBuilder = new Temperature(
          current: temp, temperatureUnit: TemperatureUnit.celsius);
      forecasts.add(Weather(
          city: city,
          dateTime: startDateTime,
          description: randomDescription,
          cloudCoveragePercentage: generateCloudCoverageNum(randomDescription),
          temperature: tempBuilder));

      runningMin = math.min(runningMin, temp);
      runningMax = math.max(runningMax, temp);
    }

    var forecastDay = ForecastDay(
        hourlyWeather: forecasts,
        min: runningMin,
        max: runningMax,
        date: dailyDate);
    dailyDate.add(Duration(days: 1));
    return forecastDay;
  }

  Forecast generateTenDayForecast(City city) {
    List<ForecastDay> tenDayForecast = [];

    List.generate(10, (int index) {
      tenDayForecast.add(dailyForecastGenerator(city, 2, 10));
    });

    return new Forecast(days: tenDayForecast, city: city);
  }
}
