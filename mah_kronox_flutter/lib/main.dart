import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import "package:dslink_schedule/ical.dart";

import 'SchedulePage.dart';
import 'SearchPage.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MAH Schema',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SearchPage(title: 'MAH Schema'),
      routes: <String, WidgetBuilder> {
        '/schedule': (BuildContext context) => new SchedulePage(title: "MAH Schema")
      }
    );
  }
}



