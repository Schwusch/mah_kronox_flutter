import 'package:flutter/material.dart';

abstract class Action {
  Action();

  String toString() => '$runtimeType';
}

class ChangeThemeAction extends Action {
  final Brightness brightness;
  final MaterialColor primaryColor;
  final MaterialAccentColor accentColor;

  ChangeThemeAction({this.brightness, this.primaryColor, this.accentColor});
}

class AddScheduleAction extends Action {
  final String schedule;

  AddScheduleAction({this.schedule});
}

class RemoveScheduleAction extends Action {
  final String schedule;

  RemoveScheduleAction({this.schedule});
}