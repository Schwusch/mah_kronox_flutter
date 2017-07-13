import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(widget.title),
            actions: <Widget> [
              new IconButton(
                  icon: new Icon(Icons.add),
                  tooltip: "This is the settings page",
                  onPressed: () {
                    Navigator.of(context).pushNamed("/searchpage");
                  },
                )],
        ),
        body: new Text("Testar lite här bara...")
    );
  }
}