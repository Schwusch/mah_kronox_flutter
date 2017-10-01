import 'package:flutter/material.dart';
import 'package:flutter_color_picker/flutter_color_picker.dart';

import 'redux/store.dart';
import 'redux/actions.dart';
import 'redux/app_state.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String path = "/settings";

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _themeSubscription;

  @override
  void initState() {
    super.initState();
    _themeSubscription = themeStore.onChange.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _themeSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView(children: <Widget>[
        _buildDarkModeSwitch(),
        _buildPrimaryColor(),
        _buildAccentColor(),
        new Divider()
      ]),
    );
  }

  Widget _buildDarkModeSwitch() {
    final brightness = themeStore.state.theme.brightness != Brightness.light;

    return new ListTile(
        title: new Row(children: [
      new Expanded(child: new Text("Dark Mode")),
      new Switch(
          value: brightness,
          onChanged: (bool value) async {
            if (value != brightness) {
              themeStore.dispatch(new ChangeThemeAction(
                  brightness:
                      value == true ? Brightness.dark : Brightness.light));
            }
          })
    ]));
  }

  Widget _buildPrimaryColor() {
    return _buildColorTile("Primary Color", themeStore.state.primaryColor,
        () async {
      Color color = await showDialog(
          context: context,
          child: new PrimaryColorPickerDialog(
              selected: themeStore.state.primaryColor));
      if (color != null) {
        themeStore.dispatch(new ChangeThemeAction(primaryColor: color));
      }
    });
  }

  Widget _buildAccentColor() {
    return _buildColorTile("Accent Color", themeStore.state.accentColor,
        () async {
      Color color = await showDialog(
          context: context,
          child: new AccentColorPickerDialog(
              selected: themeStore.state.accentColor));
      if (color != null) {
        themeStore.dispatch(new ChangeThemeAction(accentColor: color));
      }
    });
  }

  Widget _buildColorTile(String text, ColorSwatch color, VoidCallback onTap) {
    return new ListTile(
        title: new Row(children: [
          new Expanded(child: new Text(text)),
          new Padding(
              padding: new EdgeInsets.only(right: 14.0),
              child: new ColorTile(color: color, size: 40.0, rounded: true)),
        ]),
        onTap: onTap);
  }
}
