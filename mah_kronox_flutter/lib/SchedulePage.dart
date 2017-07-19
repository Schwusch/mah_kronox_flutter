import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Drawer.dart';

import 'utils/fetchBookings.dart';
import 'utils/Booking.dart';
import 'utils/Week.dart';
import 'utils/Day.dart';

import 'redux/store.dart';
import 'redux/actions.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  static final String path = "/";

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  var _subscribtion;
  List<Booking> bookings = [];
  DateFormat timeFormatter = new DateFormat("HH:mm", "sv_SE");

  _SchedulePageState() {
    fetchAndSetBookings();
  }

  fetchAndSetBookings() {
    if(scheduleStore.state.currentSchedule != null) {
      fetchBookings(scheduleStore.state.currentSchedule).then((bookings) {
        scheduleStore.dispatch(new SetWeeksForCurrentSchedule(
            weeks: buildWeeksStructure(bookings)
        ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribtion = scheduleStore.onChange.listen((_) {
      fetchAndSetBookings();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscribtion.cancel();
  }

  Widget _createScheduleItem(Booking booking) {
    return new Card(

      elevation: 3.0,
      child: new Row(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(
                  timeFormatter.format(booking.start),
                  style: new TextStyle(
                      color: Colors.blueGrey
                  )
              ),
              new Text(
                  timeFormatter.format(booking.end),
                  style: new TextStyle(
                      color: Colors.grey
                  )
                  ),
              new Text(
                  booking.location,
                  style: new TextStyle(
                      color: Colors.blueGrey,
                  )
              )
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

  Widget _createDayCard(Day day) {
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
                        day.date,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.w500
                        ),
                    )
                ),
              ],
          ),
          new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Column(
                  children: day.bookings.map((booking) => _createScheduleItem(booking)).toList(growable: false)
              )
          )
        ],
    );
  }

  Widget _createWeekCard(Week week) {
    List<Widget> widgets = [];
    widgets.add(new Card(
      color: themeStore.state.theme.backgroundColor,
      elevation: 5.0,
      child: new Text(
          "v.${week.number}",
          textScaleFactor: 2.0,
          textAlign: TextAlign.center,
          style: new TextStyle(
              color: Colors.black87
          )
      ),
    ));

    widgets.addAll(week.days.map((day) => _createDayCard(day)));

    return new Card(
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgets
      ),
      color: themeStore.state.theme.canvasColor,
    );
  }

  List<Widget> _buildSchedule() {
    return scheduleStore.state.weeksForCurrentSchedule.map((week) =>
        _createWeekCard(week)).toList(growable: false
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(widget.title),
      ),
      body: new ListView(
          padding: new EdgeInsets.all(10.0),
          reverse: false,
          children: _buildSchedule(),
      ),
      drawer: new ScheduleDrawer()
    );
  }
}

