import 'package:flutter/material.dart';
import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/models/src/weather.dart';
import 'package:weather_app/styles.dart';
import 'package:weather_app/widget/segmented_control.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;

  const SettingsPage({Key key, this.settings}) : super(key: key);

  @override
  SettingsPageState createState() {
    return new SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  List<String> get temperatureOptions =>
      TemperatureUnit.values.map((u) => u.toString()).toList();

  void _handleCityActiveChange(bool b, String city) {
    setState(() {
      widget.settings.selectedCities[city] = b;
    });
  }

  void _handleTemperatureUnitChange(int selection) {
    setState(() {
      widget.settings.selectedTemperature =
          TemperatureUnit.values.toList()[selection];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings Page',
          style: TextStyle(color: AppColor.textColorLight),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Temperature Unit'),
            SegmentedControl(
              temperatureOptions,
              onSelectionChanged: (int selection) =>
                  _handleTemperatureUnitChange(selection),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCities.length,
                  itemBuilder: (BuildContext context, int index) {
                    var city = allCities[index];
                    return CheckboxListTile(
                      value: widget.settings.selectedCities[city],
                      title: Text(city),
                      onChanged: (bool b) => _handleCityActiveChange(b, city),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
