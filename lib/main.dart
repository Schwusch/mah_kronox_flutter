import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'SchedulePage.dart';
import 'SearchPage.dart';
import 'SettingsPage.dart';

import 'redux/store.dart';
import 'redux/app_state.dart';
import 'redux/actions.dart';

import 'utils/fileStorage.dart';

const appName = "MAH Schema";

// Entry point of the application
void main() {
  run();
}

Future run() async {
  // Show a splash screen while loading settings
  runApp(new Splash());
  await _init();
  // Launch the real app
  runApp(new App());
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            body: new Column(children: [
          new Center(
              child: new FlutterLogo(
                  colors: themeStore?.state?.theme?.accentColor ?? Colors.pink,
                  size: 80.0)),
          new Center(
              child: new Text(appName, style: new TextStyle(fontSize: 32.0))),
          new Center(
              child: new Text("för studenter på MAH",
                  style: new TextStyle(fontSize: 16.0)))
        ], mainAxisAlignment: MainAxisAlignment.center)),
        theme: themeStore?.state?.theme);
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {
  var _themeSubscription;

  _AppState() {
    _themeSubscription = themeStore.onChange.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _themeSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: themeStore.state.theme,
        title: appName,
        routes: {
          SchedulePage.path: (BuildContext context) =>  // Home
              new SchedulePage(title: "Schemavisning"), // Home
          SettingsPage.path: (BuildContext context) =>
              new SettingsPage(title: "Inställningar"),
          SearchPage.path: (BuildContext context) =>
              new SearchPage(title: "Sök")
        });
  }
}

Future<Null> _init() async {
  await initializeDateFormatting("sv", null);

  scheduleStore = new ScheduleStore();
  String scheduleStateString = await loadScheduleStateFromFile();

  if (scheduleStateString != null) {
    try {
      ScheduleState loadedState =
      ScheduleState.deserialize(JSON.decode(scheduleStateString));
      scheduleStore = new ScheduleStore(initialState: loadedState);
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
  }

  themeStore = new ThemeStore();
  String themeStateString = await loadThemeStateFromFile();

  if (themeStateString != null) {
    try {
      ThemeState loadedState =
      ThemeState.deserialize(JSON.decode(themeStateString));
      themeStore = new ThemeStore(initialState: loadedState);
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
  }
}
