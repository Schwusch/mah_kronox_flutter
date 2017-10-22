import 'package:flutter/material.dart';
import '../utils/Week.dart';
import '../utils/Day.dart';
import '../utils/Booking.dart';
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

  Map<String, dynamic> serialize() {
    return {
      kBrightnessKey: brightness == Brightness.dark,
      kPrimaryColorKey: Colors.primaries.indexOf(primaryColor),
      kAccentColorKey: Colors.accents.indexOf(accentColor),
    };
  }

  static ThemeState deserialize(Map<String, dynamic> state) {
    return new ThemeState(
      brightness: state[kBrightnessKey] ? Brightness.dark : Brightness.light,
      primaryColor: Colors.primaries[state[kPrimaryColorKey]],
      accentColor: Colors.accents[state[kAccentColorKey]],
    );
  }
}

class ScheduleState {
  final List<ScheduleMeta> schedules;
  final ScheduleMeta currentSchedule;
  final Map<String, List<Week>> weeksMap;
  final Map<String, String> signatureMap;

  ScheduleState(
      {this.schedules, this.currentSchedule, this.weeksMap, this.signatureMap});

  factory ScheduleState.initial() => new ScheduleState(
      schedules: <ScheduleMeta>[],
      currentSchedule: null,
      weeksMap: new Map(),
      signatureMap: new Map());

  ScheduleState apply(
      {List<ScheduleMeta> schedules,
      ScheduleMeta currentSchedule,
      Map<String, List<Week>> weeksMap,
      Map<String, String> signatureMap}) {
    return new ScheduleState(
        schedules: schedules ?? this.schedules,
        currentSchedule: currentSchedule ?? this.currentSchedule,
        weeksMap: weeksMap ?? this.weeksMap,
        signatureMap: signatureMap ?? this.signatureMap);
  }

  rebuildSearch() {
    this.weeksMap.forEach((String _, List<Week> weeks) {
      weeks.forEach((Week week) {
        week.days.forEach((Day day) {
          day.bookings.forEach((Booking booking) {
            StringBuffer sb = new StringBuffer()
              ..write(booking.moment)
              ..write(booking.location)
              ..write(booking.course);

            for (String teacher in booking.signatures) {
              sb.write(signatureMap[teacher] ?? teacher);
            }

            booking.searchableText = sb.toString();
          });
        });
      });
    });
  }

  Map<String, dynamic> serialize() {
    Map<String, dynamic> weeksMapsSerialized = new Map();
    weeksMap.forEach((key, value) => weeksMapsSerialized[key] =
        value.map((week) => week.serialize()).toList());

    return {
      "signatureMap": signatureMap,
      "schedules":
          schedules.map((meta) => meta.serialize()).toList(growable: false),
      "currentSchedule": currentSchedule?.serialize(),
      "weeksMap": weeksMapsSerialized
    };
  }

  static ScheduleState deserialize(Map<String, dynamic> state) {
    Map<String, dynamic> weeksMapsDeserialized = new Map();
    state["weeksMap"]?.forEach((key, value) => weeksMapsDeserialized[key] =
        value.map((week) => Week.deserialize(week)).toList());

    return new ScheduleState(
        signatureMap: state["signatureMap"],
        schedules: state["schedules"]
            .map((schedule) => ScheduleMeta.deserialize(schedule))
            .toList(),
        currentSchedule: ScheduleMeta.deserialize(state["currentSchedule"]),
        weeksMap: weeksMapsDeserialized);
  }
}

class IgnoreState {
  final Set<String> hiddenBookings;

  IgnoreState({this.hiddenBookings});

  factory IgnoreState.initial() => new IgnoreState(hiddenBookings: new Set());

  IgnoreState apply({Map<String, String> hiddenBookings}) => new IgnoreState(hiddenBookings: hiddenBookings ?? this.hiddenBookings);

  Map<String, dynamic> serialize() {
    return {
      "hiddenBookings": hiddenBookings,
    };
  }

  static IgnoreState deserialize(Map<String, dynamic> state) {
    return new IgnoreState(hiddenBookings: state["hiddenBookings"]);
  }
}
