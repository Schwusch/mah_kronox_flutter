import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'SearchPage.dart';
import 'Drawer.dart';
import 'FullScreenBooking.dart';
import 'custom_expansion_panel.dart';

import 'utils/fetchBookings.dart';
import 'utils/Booking.dart';
import 'utils/Week.dart';
import 'utils/Day.dart';
import 'utils/ScheduleMeta.dart';

import 'redux/store.dart';
import 'redux/actions.dart';
import 'redux/app_state.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  static final String path = "/";

  SchedulePage({Key k, this.title}) : super(key: k);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription<ScheduleState> _subscribtion;
  DateFormat timeFormatter = new DateFormat("HH:mm", "sv_SE");
  TabController _tabController;
  final TextEditingController _textController = new TextEditingController();
  String searchTerm = "";
  bool search = false;

  @override
  void initState() {
    super.initState();
    // Manual handling of tabcontroller circumvents known bug:
    // https://github.com/flutter/flutter/issues/11450
    // https://github.com/flutter/flutter/issues/10322
    ScheduleMeta currentSchedule = scheduleStore.state.currentSchedule;
    List<Week> weeksToDisplay =
        scheduleStore.state.weeksMap[currentSchedule?.name];
    _tabController =
        new TabController(vsync: this, length: weeksToDisplay?.length ?? 0);

    // Subscribe to Redux store changes
    _subscribtion = scheduleStore.onChange
        .listen((state) => setState(() => _updateState(state)));
  }

  _updateState(ScheduleState state) {
    // Manual handling of tabcontroller circumvents known bug:
    // https://github.com/flutter/flutter/issues/11450
    // https://github.com/flutter/flutter/issues/10322
    ScheduleMeta currentSchedule = state.currentSchedule;
    List<Week> weeksToDisplay = state.weeksMap[currentSchedule?.name];
    this._tabController = new TabController(
        vsync: this, length: weeksToDisplay?.length ?? 0, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _subscribtion.cancel();
    _tabController.dispose();
  }

  Future<Null> fetchAndSetBookings() async {
    final Completer<Null> completer = new Completer<Null>();
    if (scheduleStore.state.currentSchedule != null) {
      fetchAllSchedules(scheduleStore.state.schedules).then((weeks) {
        scheduleStore
            .dispatch(new SetWeeksForCurrentScheduleAction(weeks: weeks));
        completer.complete(null);
      }).catchError((var e) {
        completer.completeError(e);
      });
    } else {
      completer.complete(null);
    }

    return completer.future.then((_) {
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
        content: const Text("Scheman uppdaterade"),
      ));
    }).catchError((var e) {
      print(e.toString());
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: const Text("Ett fel inträffade vid hämtning av schema"),
          action: new SnackBarAction(
              label: 'PROVA IGEN',
              onPressed: () {
                _refreshIndicatorKey.currentState?.show();
              })));
    });
  }

  Widget buildSearchBar() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(children: <Widget>[
        new Flexible(
          child: new TextField(
            style: new TextStyle(fontSize: 20.0),
            autofocus: true,
            onChanged: (String str) {
              this.searchTerm = str;
            },
            decoration: new InputDecoration.collapsed(hintText: "Filtrera"),
            controller: _textController,
          ),
        ),
        new Container(
            child: new IconButton(
                icon: new Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    this.search = false;
                    _textController.clear();
                    this.searchTerm = "";
                  });
                })),
      ]),
    );
  }

  Widget _buildBookingCard(Booking booking) {
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

    List<Widget> timeAndLocationChildren = [
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

    timeAndLocationChildren.addAll(locations);

    return new InkWell(
      onLongPress: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new FullScreenBooking(booking: booking),
              fullscreenDialog: true,
            ));
      },
      child: new Row(
        children: <Widget>[
          new Container(
            child: new Column(
              children: timeAndLocationChildren,
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
                        color: themeStore.state.theme.textTheme.body1.color,
                        fontWeight: FontWeight.bold)),
                new Text(booking.moment)
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            padding: new EdgeInsets.all(5.0),
          ))
        ],
      ),
    );
  }

  Widget _buildDayColumn(Day day) {
    List bookings = day.bookings
        .where((booking) => booking.searchableText
            .toLowerCase()
            .contains(searchTerm.toLowerCase()))
        .toList(growable: false);

    if (bookings.isEmpty) {
      return new Container();
    }

    return new Column(
      children: <Widget>[
        new Padding(
            padding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  day.weekday,
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                new Text(
                  day.date,
                  textAlign: TextAlign.right,
                  style: new TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
              ],
            )),
        new Padding(
            padding: new EdgeInsets.all(5.0),
            child: new CustomExpansionPanelList(
              animationDuration: new Duration(milliseconds: 500),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    if (isExpanded) {
                      ignoreStore.dispatch(
                          new AddHiddenBooking(booking: bookings[index]));
                    } else {
                      ignoreStore.dispatch(
                          new RemoveHiddenBooking(booking: bookings[index]));
                    }
                  });
                },
                children: bookings.map((Booking booking) {
                  return new ExpansionPanel(
                      headerBuilder: (_, bool isExpanded) {
                        if (isExpanded) {
                          return _buildBookingCard(booking);
                        } else
                          return null;
                      },
                      body: new Container(),
                      isExpanded: !ignoreStore.state.hiddenBookings
                          .contains(booking.uuid));
                }).toList()))
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    ScheduleMeta currentSchedule = scheduleStore.state.currentSchedule;

    return <Widget>[
      new IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              search = true;
            });
          }),
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
                  title: new Text(currentSchedule?.givenName),
                  children: <Widget>[
                    new ListTile(
                      title: new Text(currentSchedule.name),
                      subtitle: new Text(currentSchedule.description),
                      isThreeLine: true,
                      dense: true,
                    ),
                    new ButtonTheme.bar(
                      child: new ButtonBar(
                        children: <Widget>[
                          new FlatButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop())
                        ],
                      ),
                    ),
                  ],
                ));
          })
    ];
  }

  Widget _buildTabbedBody() {
    ScheduleMeta currentSchedule = scheduleStore.state.currentSchedule;
    List<Week> weeksToDisplay =
        scheduleStore.state.weeksMap[currentSchedule.name];

    return new Scaffold(
        drawer: new ScheduleDrawer(
          refreshIndicatorKey: _refreshIndicatorKey,
        ),
        key: _scaffoldKey,
        appBar: new AppBar(
          title: search
              ? buildSearchBar()
              : new Text(currentSchedule?.givenName ?? widget.title),
          bottom: new TabBar(
            controller: this._tabController,
            tabs: weeksToDisplay
                ?.map((Week week) => new Tab(text: "v. ${week.number}"))
                ?.toList(),
            isScrollable: true,
          ),
          actions: search ? null : _buildAppBarActions(),
        ),
        body: new RefreshIndicator(
          onRefresh: fetchAndSetBookings,
          key: _refreshIndicatorKey,
          child: new TabBarView(
              controller: this._tabController,
              children: weeksToDisplay.map((Week week) {
                return new ListView(
                    children:
                        week.days.map((day) => _buildDayColumn(day)).toList());
              })?.toList()),
        ));
  }

  Widget _buildEmptyBody(Widget widget) {
    return new Scaffold(
      drawer: new ScheduleDrawer(
        refreshIndicatorKey: _refreshIndicatorKey,
      ),
      body: new RefreshIndicator(
        onRefresh: fetchAndSetBookings,
        key: _refreshIndicatorKey,
        child: new Center(child: widget),
      ),
      appBar: new AppBar(
        title: new Text(scheduleStore.state.currentSchedule?.givenName ??
            scheduleStore.state.currentSchedule?.name ??
            "Inget Schema valt"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScheduleMeta currentSchedule = scheduleStore.state.currentSchedule;
    List<Week> weeksToDisplay =
        scheduleStore.state.weeksMap[currentSchedule?.name];
    List<ScheduleMeta> schedules = scheduleStore.state.schedules;

    if (currentSchedule == null ||
        schedules.isEmpty ||
        !schedules.contains(currentSchedule) && currentSchedule.name != "all") {
      if (schedules.isNotEmpty) {
        scheduleStore
            .dispatch(new SetCurrentScheduleAction(schedule: schedules.first));
        _refreshIndicatorKey.currentState?.show();
      }
      return _buildEmptyBody(new RaisedButton(
        onPressed: () => Navigator.of(context).pushNamed(SearchPage.path),
        child: new Text("Lägg till schema"),
      ));
    } else if (weeksToDisplay == null || weeksToDisplay.isEmpty) {
      _refreshIndicatorKey.currentState?.show();
      return _buildEmptyBody(new RaisedButton(
        onPressed: () {
          _refreshIndicatorKey.currentState?.show();
        },
        child: new Icon(Icons.refresh),
      ));
    } else {
      return _buildTabbedBody();
    }
  }
}
