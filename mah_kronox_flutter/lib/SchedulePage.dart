import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  static final String path = "/";

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>{


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(widget.title),
            actions: <Widget> [
              new IconButton(
                icon: new Icon(Icons.settings),
                tooltip: "Test button to show another view",
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              )],
        ),
        body: new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Card(
                  child: new Text("First post")
              ),
              new Card(
                  child: new Text("second post")
              )
            ],
        )
    );
  }
}

