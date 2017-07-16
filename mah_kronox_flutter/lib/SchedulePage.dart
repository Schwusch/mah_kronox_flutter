import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  static final String path = "/";

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {

  Widget _createScheduleItem() {
    return new Card(

          elevation: 2.0,
          child: new Row(
              children: <Widget>[
                new Text(
                    "tid",
                    textAlign: TextAlign.left,
                    ),
                new Text(
                    "Kurs",
                    textAlign: TextAlign.right,
                    )
              ],
              )
      );
  }

  Widget _createDayCard() {
    return new Column(
        children: <Widget>[
          new Row(
              children: <Widget>[
                new Padding(
                    padding: new EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 10.0
                    ),
                    child: new Text(
                        "måndag: 56 september",
                        textAlign: TextAlign.left,
                        )
                ),

              ],
              ),
          new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Column(
                  children: <Widget>[
                    _createScheduleItem()
                  ],
              )
          )
        ],
        );
  }

  Widget _createWeekCard() {
    return new Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Card(
                  color: Colors.deepPurple,
                  elevation: 3.0,
                  child: new Text(
                      "Vecka",
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70
                      )
                  ),
                  ),
              _createDayCard(),
              _createDayCard(),
              _createDayCard(),
              _createDayCard(),
              _createDayCard(),
              _createDayCard()
            ],
            )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(widget.title),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.settings),
                  tooltip: "Test button to show another view",
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                  )
            ],
            ),

        body: new ListView.builder(
            padding: new EdgeInsets.all(10.0),
            reverse: false,
            itemBuilder: (_, index) => _createWeekCard(),
            itemCount: 1,
            )
    );
  }
}

