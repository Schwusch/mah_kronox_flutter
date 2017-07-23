import 'package:flutter/material.dart';
import 'utils/fetchBookings.dart';
import 'utils/ScheduleMeta.dart';
import 'redux/store.dart';
import 'redux/actions.dart';
import 'SettingsPage.dart';
import 'SearchPage.dart';

class ScheduleDrawer extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => new _ScheduleDrawerState();
}

class _ScheduleDrawerState extends State<ScheduleDrawer> {
  var _subscription;

  refreshAllSchedules() {
    fetchAllSchedules(scheduleStore.state.schedules).then((weeks) {
      scheduleStore.dispatch(new SetWeeksForCurrentScheduleAction(
          weeks: weeks
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new ScheduleDrawerHeader(),
      new ListTile(
        leading: new Icon(Icons.settings),
        title: new Text("Inställningar"),
        onTap: () => Navigator.of(context).pushNamed(SettingsPage.path),
      ),
      new Divider(),
      new ListTile(
          title: new Text("Mina Sheman"),
          dense: true
      ),
      new ListTile(
        leading: new Icon(Icons.all_inclusive),
        title: new Text("Visa alla scheman"),
        onTap: () {
          scheduleStore.dispatch(new SetCurrentScheduleAction(schedule: new ScheduleMeta(
            name: "all",
            description: "Alla mina scheman",
          )));

          refreshAllSchedules();
          Navigator.of(context).pop();
        },
      ),
    ];

    children.addAll(scheduleStore.state.schedules.map((ScheduleMeta schedule) {
      return new ListTile(
        leading: new Icon(Icons.schedule),
        title: new Text(schedule.name),
        onTap: () {
          scheduleStore.dispatch(new SetCurrentScheduleAction(schedule: schedule));
          refreshAllSchedules();
          Navigator.of(context).pop();
        },
        onLongPress: () {
          showDialog(
              context: context,
              child: new AlertDialog(
                title: new Text("Ta bort schema"),
                content: new Text("Vill du ta bort ${schedule.name}?"),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        scheduleStore.dispatch(
                          new RemoveScheduleAction(schedule: schedule)
                        );
                        Navigator.of(context).pop();
                      },
                      child: new Text("Ta bort")
                  ),
                  new FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: new Text("Tillbaka")
                  )
                ],
              )
          );
        },
      );
    }));

    children.addAll([
      new ListTile(
        leading: new Icon(Icons.add),
        title: new Text("Lägg till Schema"),
        onTap: () => Navigator.of(context).pushNamed(SearchPage.path),
      ),
      new Divider(),
      new AboutListTile(
        applicationName: "MAH Schema",
        applicationVersion: "0.0.1",
      )
    ]);

    return new Drawer(
      child: new ListView(
        children: children
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _subscription = scheduleStore.onChange.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}

class ScheduleDrawerHeader extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new UserAccountsDrawerHeader(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/images/mah.jpg"),
              fit: BoxFit.cover
          )
      ),
      accountName: new Text("Malmö Högskola"),
      accountEmail: null,
      currentAccountPicture: new CircleAvatar(
        backgroundImage: new AssetImage("assets/images/logo.jpg"),
      ),
    );
  }
}