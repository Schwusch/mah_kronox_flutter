import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import "package:dslink_schedule/ical.dart";

import 'SchedulePage.dart';
import 'SearchPage.dart';
import 'SettingsPage.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Schemavisning',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new SchedulePage(title: "Schemavisning"),
        '/settings': (BuildContext context) => new SettingsPage(title: "Inställingar"),
        '/searchpage': (BuildContext context) => new SearchPage(title: "Sök")
      }
    );
  }
}



