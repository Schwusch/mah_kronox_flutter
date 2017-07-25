import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Drawer.dart';
import 'FullScreenBooking.dart';

import 'utils/fetchBookings.dart';
import 'utils/Booking.dart';
import 'utils/Week.dart';
import 'utils/Day.dart';
import 'utils/ScheduleMeta.dart';

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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _subscribtion;
  List<Booking> bookings = [];
  DateFormat timeFormatter = new DateFormat("HH:mm", "sv_SE");

  _SchedulePageState() {
    if (scheduleStore.state.schedules.isNotEmpty) {
      fetchAndSetBookings();
    }
  }

  Future<Null> fetchAndSetBookings() {
    final Completer<Null> completer = new Completer<Null>();
    if (scheduleStore.state.currentSchedule != null) {
      fetchAllSchedules(scheduleStore.state.schedules).then((weeks) {
        completer.complete(null);
        scheduleStore
            .dispatch(new SetWeeksForCurrentScheduleAction(weeks: weeks));
      });
    } else {
      completer.complete(null);
    }

    return completer.future.then((_) {
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: const Text("Scheman uppdaterade"),
          action: new SnackBarAction(
              label: 'IGEN',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
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
    String teachers = "";
    Map signaturemap = scheduleStore.state.signatureMap;

    for (String teacher in booking.signatures) {
      teachers += (signaturemap[teacher] ?? teacher) + ", ";
    }

    Iterable<Widget> locations =
        booking.location.split(" ").map((loc) => new Text(
              loc,
              style:
                  new TextStyle(color: themeStore.state.accentColor.shade700),
            ));

    List<Widget> leftColumnChildren = [
      new Text(timeFormatter.format(booking.start),
          style: new TextStyle(
              fontSize: 24.0,
              color: themeStore.state.primaryColor.shade200,
              fontWeight: FontWeight.bold)),
      new Text(timeFormatter.format(booking.end),
          style: new TextStyle(
              fontSize: 24.0,
              color: themeStore.state.theme.textTheme.caption.color,
              fontWeight: FontWeight.bold)),
    ];

    leftColumnChildren.addAll(locations);

    return new Card(
        elevation: 3.0,
        child: new InkWell(
          onLongPress: () {
            Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new FullScreenBooking(booking: booking),
              fullscreenDialog: true,
            ));
          },
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
                    new Text(teachers,
                        style: new TextStyle(
                            color:
                                themeStore.state.theme.textTheme.caption.color,
                            fontWeight: FontWeight.bold)),
                    new Text(booking.moment)
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                padding: new EdgeInsets.all(5.0),
              ))
            ],
          ),
        ));
  }

  Widget _createDayCard(Day day) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
                padding:
                    new EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: new Text(
                  day.date,
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontWeight: FontWeight.w500),
                )),
          ],
        ),
        new Padding(
            padding: new EdgeInsets.all(5.0),
            child: new Column(
                children: day.bookings
                    .map((booking) => _createScheduleItem(booking))
                    .toList(growable: false)))
      ],
    );
  }

  Widget _createWeekCard(Week week) {
    List<Widget> widgets = [];
    widgets.add(new Card(
      color: themeStore.state.theme.primaryColor,
      elevation: 5.0,
      child: new Text("v.${week.number}",
          textScaleFactor: 2.0,
          textAlign: TextAlign.center,
          style: themeStore.state.theme.primaryTextTheme.body1),
    ));

    widgets.addAll(week.days.map((day) => _createDayCard(day)));

    return new Card(
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets),
      color: themeStore.state.brightness == Brightness.light
          ? themeStore.state.primaryColor.shade50
          : themeStore.state.theme.canvasColor,
    );
  }

  List<Widget> _buildSchedule() {
    return scheduleStore
        .state.weeksMap[scheduleStore.state.currentSchedule?.name]
        .map((week) => _createWeekCard(week))
        .toList(growable: false);
  }

  Widget buildBody() {
    if (scheduleStore
            .state.weeksMap[scheduleStore.state.currentSchedule?.name] !=
        null) {
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
    ScheduleMeta currentSchedule = scheduleStore.state.currentSchedule;

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text(currentSchedule?.givenName ?? widget.title),
            actions: currentSchedule != null
                ? <Widget>[
                    new IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: () {
                          _refreshIndicatorKey.currentState?.show();
                        }),
                    new IconButton(
                        icon: const Icon(Icons.info),
                        tooltip: 'Information',
                        onPressed: () {
                          showDialog(
                              context: context,
                              child: new SimpleDialog(
                                title: new Text(currentSchedule.givenName),
                                children: <Widget>[
                                  new ListTile(
                                    title: new Text(currentSchedule.name),
                                    subtitle:
                                        new Text(currentSchedule.description),
                                  ),
                                  new ButtonTheme.bar(
                                    child: new ButtonBar(
                                      children: <Widget>[
                                        new FlatButton(
                                            child: const Text('OK'),
                                            onPressed: () =>
                                                Navigator.of(context).pop())
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                        })
                  ]
                : null),
        body: new RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchAndSetBookings,
            child: buildBody()),
        drawer: new ScheduleDrawer());
  }
}