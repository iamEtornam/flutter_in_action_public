import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/models/src/countries.dart';
import 'package:weather_app/styles.dart';

class AddNewCityPage extends StatefulWidget {
  final AppSettings settings;

  const AddNewCityPage({Key key, this.settings}) : super(key: key);

  @override
  _AddNewCityPageState createState() => _AddNewCityPageState();
}

class _AddNewCityPageState extends State<AddNewCityPage> {
  City _newCity = new City.fromUserInput();
  bool _formChanged = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add City",
          style: TextStyle(color: AppColor.textColorLight),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          onChanged: _onFormChange,
          onWillPop: _onWillPop,
          child: Column(
            children: <Widget>[
              _titleField,
              _stateName,
              _countryDropdownField,
              _isDefaultField,
              Divider(
                height: 32.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                        textColor: Colors.red[400],
                        child: Text("Cancel"),
                        onPressed: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop(false);
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Colors.blue[400],
                      child: Text("Submit"),
                      onPressed: _formChanged
                          ? () {
                              _formKey.currentState.save();
                              _handleAddNewCity();
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _titleField {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          onSaved: (String val) => _newCity.name = val,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            helperText: "Required",
            labelText: "City name",
          ),
          autofocus: true,
          autovalidate: _formChanged,
          validator: (String val) {
            if (val.isEmpty) {
              return "Field cannot be left blank";
            }
          },
        ));
  }

  Widget get _stateName {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          onSaved: (String val) => print(val),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            helperText: "Optional",
            labelText: "State or Territory name",
          ),
          validator: (String val) {
            if (val.isEmpty) {
              return "Field cannot be left blank";
            }
          },
        ));
  }

  Widget get _countryDropdownField {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropDownExpanded<Country>(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Country",
        ),
        value: _newCity.country ?? Country.AD,
        onChanged: (Country newSelection) {
          setState(() => _newCity.country = newSelection);
        },
        items: Country.ALL.map((Country country) {
          return DropdownMenuItem(value: country, child: Text(country.name));
        }).toList(),
      ),
    );
  }

  bool _isDefaultFlag = false;

  Widget get _isDefaultField {
    return FormField(
        onSaved: (val) => _newCity.active = _isDefaultFlag,
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Default city?"),
              Checkbox(
                value: _isDefaultFlag,
                onChanged: (val) {
                  setState(() => _isDefaultFlag = val);
                },
              ),
            ],
          );
        });
  }

  void _onFormChange() {
    if (_formChanged) return;
    setState(() {
      _formChanged = true;
    });
  }

  void _handleAddNewCity() {
    var city = City(
      name: _newCity.name,
      country: _newCity.country,
      active: true,
    );

    allAddedCities.add(city);
  }

  Future<bool> _onWillPop() {
    if (!_formChanged) return Future<bool>.value(true);
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
                content: Text(
                    "Are you sure you want to abandon the form? Any changes will be lost."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(false),
                    textColor: Colors.black,
                  ),
                  FlatButton(
                    child: Text("Abandon"),
                    textColor: Colors.red,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ) ??
              false;
        });
  }
}

/// This is an almost exact replica of the built-in
/// DropDownFormField. There's a bug in the original
/// Widget that causes the input value to expand furhter than the
/// input field, because it needs to be wrapped in an `Expanded`.
class DropDownExpanded<T> extends FormField<T> {
  final bool isExpanded;
  final initialValue;

  DropDownExpanded({
    this.isExpanded,
    this.initialValue,
    this.onChanged,
    Key key,
    T value,
    @required List<DropdownMenuItem<T>> items,
    InputDecoration decoration = const InputDecoration(),
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    Widget hint,
  })  : assert(decoration != null),
        super(
            key: key,
            onSaved: onSaved,
            initialValue: value,
            validator: validator,
            builder: (FormFieldState<T> field) {
              final InputDecoration effectiveDecoration = decoration
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return InputDecorator(
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                isEmpty: value == null,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    isDense: true,
                    value: value,
                    items: items,
                    hint: hint,
                    isExpanded: isExpanded,
                    onChanged: field.didChange,
                  ),
                ),
              );
            });

  /// Called when the user selects an item.
  final ValueChanged<T> onChanged;

  @override
  FormFieldState<T> createState() => _DropdownButtonFormFieldState<T>();
}

class _DropdownButtonFormFieldState<T> extends FormFieldState<T> {
  @override
  DropDownExpanded<T> get widget => super.widget;

  @override
  void didChange(T value) {
    super.didChange(value);
    if (widget.onChanged != null) widget.onChanged(value);
  }
}
