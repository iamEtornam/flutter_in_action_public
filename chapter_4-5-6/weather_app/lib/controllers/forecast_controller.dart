import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/models/src/forecast_animation_state.dart';
import 'package:weather_app/models/src/weather.dart';
import 'package:weather_app/utils/generate_weather_data.dart';

class ForecastController {
  final City city;
  Forecast forecast;
  ForecastDay selectedDay;
  Weather selectedHourlyTemperature;
  DateTime _today = new DateTime.now();

  ForecastController(City this.city) {
    var helper = new WeatherDataHelper();
    forecast = helper.generateTenDayForecast(city);
    selectedDay = Forecast.getSelectedDayForecast(
        forecast, DateTime(_today.year, _today.month, _today.day));

    selectedHourlyTemperature = ForecastDay.getHourSelection(
        selectedDay, DateTime.now().toLocal().hour);
  }

  ForecastAnimationState getDataForNextAnimationState(int index) {
    var hour = getSelectedHourFromTabIndex(index);
    var newSelection = ForecastDay.getHourSelection(selectedDay, hour);
    var endAnimationState = new ForecastAnimationState.stateForNextSelection(
        newSelection.dateTime.hour, newSelection.description);

    // update selectedHourlyTemperature to currentChoice
    selectedHourlyTemperature = newSelection;
    return endAnimationState;
  }

  int getSelectedHourFromTabIndex(int index) {
    return selectedDay.hourlyWeather[index].dateTime.hour;
  }
}
