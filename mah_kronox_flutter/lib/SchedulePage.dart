import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final String title;

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>{


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(widget.title)
        ),
        body: new Text("lolz")
    );
  }
}