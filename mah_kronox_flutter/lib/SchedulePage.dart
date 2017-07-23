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
      fetchAllBookings(scheduleStore.state.schedules).then((bookings) {
        scheduleStore.dispatch(new SetWeeksForCurrentScheduleAction(
            weeks: buildWeeksStructureMap(bookings)
        ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribtion = scheduleStore.onChange.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscribtion.cancel();
  }

  Widget _createScheduleItem(Booking booking) {
    Iterable<Widget> locations = booking.location.split(" ").map((loc) =>
      new Text(
        loc,
        style: new TextStyle(color: themeStore.state.accentColor.shade700),
      ));

    List<Widget> leftColumnChildren = [
      new Text(
          timeFormatter.format(booking.start),
          style: new TextStyle(
            fontSize: 24.0,
            color: themeStore.state.primaryColor.shade200,
            fontWeight: FontWeight.bold
          )
      ),
      new Text(
          timeFormatter.format(booking.end),
          style: new TextStyle(
            fontSize: 24.0,
            color: themeStore.state.theme.textTheme.caption.color,
            fontWeight: FontWeight.bold
          )
      ),
    ];

    leftColumnChildren.addAll(locations);

    return new Card(
      elevation: 3.0,
      child: new Container(
        child: new Row(
          children: <Widget>[
            new Container(
              child: new Column(
                children: leftColumnChildren,
              ),
              padding: new EdgeInsets.all(5.0),
              width: 110.0,
            ),
            new Flexible(
              child: new Container(
                child: new Column(
                  children: <Widget>[
                    new Text(booking.course),
                    new Text(booking.signatures.toString()),
                    new Text(booking.moment)
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                padding: new EdgeInsets.all(5.0),
              )
            )
          ],
        ),
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
              padding: new EdgeInsets.all(5.0),
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
      color: themeStore.state.theme.primaryColor,
      elevation: 5.0,
      child: new Text(
          "v.${week.number}",
          textScaleFactor: 2.0,
          textAlign: TextAlign.center,
          style: themeStore.state.theme.primaryTextTheme.body1
      ),
    ));

    widgets.addAll(week.days.map((day) => _createDayCard(day)));

    return new Card(
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgets
      ),
      color: themeStore.state.brightness == Brightness.light ? themeStore.state.primaryColor.shade50 : themeStore.state.theme.canvasColor,
    );
  }

  List<Widget> _buildSchedule() {
    return scheduleStore.state.weeksMap[scheduleStore.state.currentSchedule.name].map((week) =>
        _createWeekCard(week)).toList(growable: false
    );
  }

  Widget buildBody() {
    if(scheduleStore.state.weeksMap[scheduleStore.state.currentSchedule.name] != null) {
      return new ListView(
        padding: new EdgeInsets.all(5.0),
        reverse: false,
        children: _buildSchedule(),
      );
    }

    return new Center(
      child: new Text("Inget schema valt"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(scheduleStore.state.currentSchedule.givenName ?? widget.title),
      ),
      body: buildBody(),
      drawer: new ScheduleDrawer()
    );
  }
}

