import 'package:flutter/material.dart';
import '../utils/Week.dart';

class ThemeState {
  static final kBrightnessKey = "BrightnessKey";
  static final kPrimaryColorKey = "PrimaryColorKey";
  static final kAccentColorKey = "kAccentColorKey";

  final ThemeData _theme;
  final Brightness brightness;
  final MaterialColor primaryColor;
  final MaterialAccentColor accentColor;

  ThemeData get theme => _theme;

  ThemeState({this.brightness, this.primaryColor, this.accentColor})
      : _theme = new ThemeData(
      brightness: brightness,
      primarySwatch: primaryColor,
      accentColor: accentColor);

  factory ThemeState.initial() => new ThemeState(
      brightness: Brightness.light,
      primaryColor: Colors.red,
      accentColor: Colors.lightBlueAccent);

  ThemeState apply(
      {Brightness brightness,
        MaterialColor primaryColor,
        MaterialAccentColor accentColor}) {
    return new ThemeState(
        brightness: brightness ?? this.brightness,
        primaryColor: primaryColor ?? this.primaryColor,
        accentColor: accentColor ?? this.accentColor);
  }
}

class ScheduleState {
  final List<String> schedules;
  final String currentSchedule;
  final List<Week> weeksForCurrentSchedule;

  ScheduleState({this.schedules, this.currentSchedule, this.weeksForCurrentSchedule});

  factory ScheduleState.initial() => new ScheduleState(schedules: <String>[], currentSchedule: null, weeksForCurrentSchedule: []);

  ScheduleState apply({List<String> schedules, String currentSchedule, List<Week> weeksForCurrentSchedule}) {
    return new ScheduleState(
        schedules: schedules ?? this.schedules,
        currentSchedule: currentSchedule ?? this.currentSchedule,
        weeksForCurrentSchedule: weeksForCurrentSchedule ?? this.weeksForCurrentSchedule
    );
  }

  Map<String, dynamic> serialize() {
    return {
     "schedules": schedules,
      "currentSchedule": currentSchedule,
      "weeksForCurrentSchedule": weeksForCurrentSchedule.map((week) => week.serialize()).toList()
    };
  }

  static ScheduleState deserialize(Map<String, dynamic> state) {
    return new ScheduleState(
      schedules: state["schedules"],
      currentSchedule: state["currentSchedule"],
      weeksForCurrentSchedule: state["weeksForCurrentSchedule"].map((week) => Week.deserialize(week)).toList()
    );
  }
}