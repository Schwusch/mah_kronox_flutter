import 'package:flutter/material.dart';
import '../utils/Week.dart';
import '../utils/ScheduleMeta.dart';

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
  final List<ScheduleMeta> schedules;
  final ScheduleMeta currentSchedule;
  final Map<String, List<Week>> weeksMap;

  ScheduleState({this.schedules, this.currentSchedule, this.weeksMap});

  factory ScheduleState.initial() => new ScheduleState(schedules: <ScheduleMeta>[], currentSchedule: null, weeksMap: new Map());

  ScheduleState apply({List<ScheduleMeta> schedules, ScheduleMeta currentSchedule, Map<String, List<Week>> weeksMap}) {
    return new ScheduleState(
        schedules: schedules ?? this.schedules,
        currentSchedule: currentSchedule ?? this.currentSchedule,
        weeksMap: weeksMap ?? this.weeksMap
    );
  }

  Map<String, dynamic> serialize() {
    Map<String, dynamic> weeksMapsSerialized = new Map();
    weeksMap.forEach((key, value) =>
      weeksMapsSerialized[key] = value.map((week) => week.serialize()).toList()
    );

    return {
     "schedules": schedules.map((meta) => meta.serialize()).toList(growable: false),
      "currentSchedule": currentSchedule?.serialize(),
      "weeksMap": weeksMapsSerialized
    };
  }

  static ScheduleState deserialize(Map<String, dynamic> state) {
    Map<String, dynamic> weeksMapsDeserialized = new Map();
    state["weeksMap"]?.forEach((key, value) =>
        weeksMapsDeserialized[key] = value.map((week) => Week.deserialize(week)).toList()
    );

    return new ScheduleState(
      schedules: state["schedules"].map((schedule) => ScheduleMeta.deserialize(schedule)).toList(),
      currentSchedule: ScheduleMeta.deserialize(state["currentSchedule"]),
      weeksMap: weeksMapsDeserialized
    );
  }
}