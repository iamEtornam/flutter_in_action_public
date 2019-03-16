import 'package:flutter/material.dart';
import 'package:weather_app/controllers/forecast_controller.dart';
import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/models/src/forecast_animation_state.dart';
import 'package:weather_app/models/src/offset_sequence_animation.dart';
import 'package:weather_app/models/src/weather.dart';
import 'package:weather_app/utils/date_utils.dart';
import 'package:weather_app/utils/flutter_ui_utils.dart' as ui;
import 'package:weather_app/utils/forecast_animation_utils.dart' as utils;
import 'package:weather_app/utils/math_utils.dart';
import 'package:weather_app/widget/clouds_background.dart';
import 'package:weather_app/widget/color_transition_box.dart';
import 'package:weather_app/widget/color_transition_text.dart';
import 'package:weather_app/widget/forecast_table.dart';
import 'package:weather_app/widget/sun_background.dart';
import 'package:weather_app/widget/time_picker_row.dart';
import 'package:weather_app/widget/transition_appbar.dart';

class ForecastPage extends StatefulWidget {
  final PopupMenuButton menu;
  final Widget settingsButton;
  final AppSettings settings;

  const ForecastPage({
    Key key,
    this.menu,
    this.settingsButton,
    @required this.settings,
  }) : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage>
    with TickerProviderStateMixin {
  int activeTabIndex = 0;
  ForecastController _forecastController;
  AnimationController _animationController;
  AnimationController _weatherConditionAnimationController;
  ColorTween _colorTween;
  ColorTween _backgroundColorTween;
  ColorTween _textColorTween;
  ColorTween _cloudColorTween;
  Tween<Offset> _positionOffsetTween;
  TweenSequence<Offset> _cloudPositionOffsetTween;
  ForecastAnimationState currentAnimationState;
  ForecastAnimationState nextAnimationState;
  Offset verticalDragStart;

  @override
  void initState() {
    super.initState();
    _render();
  }

  @override
  void didUpdateWidget(ForecastPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _render();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _render() {
    _forecastController = new ForecastController(widget.settings.activeCity);
    var startTime = _forecastController.selectedHourlyTemperature.dateTime.hour;
    var startTabIndex = utils.hours.indexOf(startTime);
    currentAnimationState =
        _forecastController.getDataForNextAnimationState(startTabIndex);
    _handleStateChange(startTabIndex);
  }

  void _handleStateChange(int activeIndex) {
    if (activeIndex == activeTabIndex) return;
    nextAnimationState =
        _forecastController.getDataForNextAnimationState(activeIndex);
    _buildAnimationController();
    _buildTweens();
    _initAnimation();
    setState(() => activeTabIndex = activeIndex);
    // for next time the animation fires
    currentAnimationState = nextAnimationState;
  }

  void _handleDragEnd(DragUpdateDetails d, BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var dragEnd = d.globalPosition.dy;
    var percentage = (dragEnd / screenHeight) * 100.0;
    var scaleToTimesOfDay = (percentage ~/ 12).toInt();
    if (scaleToTimesOfDay > 7) scaleToTimesOfDay = 7;
    _handleStateChange(scaleToTimesOfDay);
  }

  void _initAnimation() {
    _animationController.forward();
    _weatherConditionAnimationController.forward();
  }

  void _buildAnimationController() {
    _animationController?.dispose();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _weatherConditionAnimationController?.dispose();
    _weatherConditionAnimationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
  }

  void _buildTweens() {
    _colorTween = new ColorTween(
      begin: currentAnimationState.sunColor,
      end: nextAnimationState.sunColor,
    );
    _backgroundColorTween = new ColorTween(
      begin: currentAnimationState.backgroundColor,
      end: nextAnimationState.backgroundColor,
    );
    _textColorTween = new ColorTween(
      begin: currentAnimationState.textColor,
      end: nextAnimationState.textColor,
    );
    _cloudColorTween = new ColorTween(
      begin: currentAnimationState.cloudColor,
      end: nextAnimationState.cloudColor,
    );
    _positionOffsetTween = new Tween<Offset>(
      begin: currentAnimationState.sunOffsetPosition,
      end: nextAnimationState.sunOffsetPosition,
    );

    var cloudOffsetSequence = new OffsetSequence.fromBeginAndEndPositions(
        currentAnimationState.cloudOffsetPosition,
        nextAnimationState.cloudOffsetPosition);
    _cloudPositionOffsetTween = new TweenSequence<Offset>(
      <TweenSequenceItem<Offset>>[
        TweenSequenceItem<Offset>(
          weight: 50.0,
          tween: Tween<Offset>(
            begin: cloudOffsetSequence.positionA,
            end: cloudOffsetSequence.positionB,
          ),
        ),
        TweenSequenceItem<Offset>(
          weight: 50.0,
          tween: Tween<Offset>(
            begin: cloudOffsetSequence.positionB,
            end: cloudOffsetSequence.positionC,
          ),
        ),
      ],
    );
  }

  List<String> get _humanReadableHours {
    return utils.hours.map((hour) => '$hour:00').toList();
  }

  String get _weatherDescription {
    var day = DateUtils.weekdays[
        _forecastController.selectedHourlyTemperature.dateTime.weekday];
    var description = Weather.displayValues[
        _forecastController.selectedHourlyTemperature.description];
    return "$day. ${description.replaceFirst(description[0], description[0].toUpperCase())}.";
  }

  String get _currentTemp {
    var unit = utils.temperatureLabels[widget.settings.selectedTemperature];
    var temp =
        _forecastController.selectedHourlyTemperature.temperature.current;

    if (widget.settings.selectedTemperature == TemperatureUnit.fahrenheit) {
      temp = Temperature.celsiusToFahrenheit(temp);
    }
    return '$temp $unit';
  }

  bool get isRaining =>
      _forecastController.selectedHourlyTemperature.description ==
      WeatherDescription.rain;

  @override
  Widget build(BuildContext context) {
    var forecastContent = ForecastTableView(
      settings: widget.settings,
      controller: _animationController,
      textColorTween: _textColorTween,
      forecast: _forecastController.forecast,
    );

    var mainContent = Container(
      padding: EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: <Widget>[
          ColorTransitionText(
            text: _weatherDescription,
            style: Theme.of(context).textTheme.headline,
            animation: _textColorTween.animate(_animationController),
          ),
          ColorTransitionText(
            text: _currentTemp,
            style: Theme.of(context).textTheme.display3,
            animation: _textColorTween.animate(_animationController),
          ),
        ],
      ),
    );

    var timePickerRow = TimePickerRow(
      tabItems: _humanReadableHours,
      forecastController: _forecastController,
      onTabChange: (int activeIndex) => _handleStateChange(activeIndex),
      startIndex: activeTabIndex,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ui.appBarHeight(context)),
        child: TransitionAppbar(
          animation: _backgroundColorTween.animate(_animationController),
          title: ColorTransitionText(
            text: _forecastController.selectedHourlyTemperature.city.name,
            style: Theme.of(context).textTheme.headline,
            animation: _textColorTween.animate(_animationController),
          ),
          actionIcon: widget.settingsButton,
          leadingAction: widget.menu,
        ),
      ),
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            widget.settings.selectedTemperature == TemperatureUnit.celsius
                ? widget.settings.selectedTemperature =
                    TemperatureUnit.fahrenheit
                : widget.settings.selectedTemperature = TemperatureUnit.celsius;
          });
        },
        onVerticalDragUpdate: (v) {
          _handleDragEnd(v, context);
        },
        child: ColorTransitionBox(
          animation: _backgroundColorTween.animate(_animationController),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Stack(
              children: <Widget>[
                SlideTransition(
                  position: _positionOffsetTween.animate(
                    _animationController.drive(
                      CurveTween(curve: Curves.bounceOut),
                    ),
                  ),
                  child:
                      Sun(animation: _colorTween.animate(_animationController)),
                ),
                SlideTransition(
                  position: _cloudPositionOffsetTween.animate(
                      _weatherConditionAnimationController
                          .drive(CurveTween(curve: Curves.bounceOut))),
                  child: Clouds(
                    isRaining: isRaining,
                    animation: _cloudColorTween.animate(_animationController),
                  ),
                ),
                Column(
                  verticalDirection: VerticalDirection.up,
                  children: <Widget>[
                    forecastContent,
                    mainContent,
                    Flexible(child: timePickerRow),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
