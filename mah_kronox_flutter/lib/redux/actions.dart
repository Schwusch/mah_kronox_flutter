import 'package:flutter/material.dart';
import '../utils/Week.dart';

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

class SetCurrentScheduleAction extends Action {
  final String schedule;

  SetCurrentScheduleAction({this.schedule});
}

class SetWeeksForCurrentSchedule extends Action {
  final List<Week> weeks;

  SetWeeksForCurrentSchedule({this.weeks});
}