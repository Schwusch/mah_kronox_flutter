import 'package:flutter/material.dart';
import 'utils/Booking.dart';
import 'utils/fetchBookings.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  static final String path = "/";

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Booking> bookings = [];
  DateFormat formatter = new DateFormat("HH:mm");
  _SchedulePageState() {
    fetchBookings("tgsya15h").then((bookings) {
      setState(() {
        this.bookings = bookings;
      });
    });
  }

  Widget _createScheduleItem(Booking booking) {
    return new Card(

      elevation: 2.0,
      child: new Row(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(formatter.format(booking.start)),
              new Text(formatter.format(booking.end)),
              new Text(booking.location)
            ],
          ),
          new Flexible(
            child: new Column(
              children: <Widget>[
                new Text(booking.course),
                new Text(booking.signatures.toString()),
                new Text(booking.moment)
              ],
            )
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
                    //_createScheduleItem()
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
            itemBuilder: (_, index) => _createScheduleItem(bookings[index]),
            itemCount: bookings.length,
            )
    );
  }
}

