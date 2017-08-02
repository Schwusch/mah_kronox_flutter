import 'package:flutter/material.dart';
import '../utils/Week.dart';
import '../utils/ScheduleMeta.dart';

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
  final ScheduleMeta schedule;

  AddScheduleAction({this.schedule});
}

class RemoveScheduleAction extends Action {
  final String schedule;

  RemoveScheduleAction({this.schedule});
}

class SetCurrentScheduleAction extends Action {
  final ScheduleMeta schedule;

  SetCurrentScheduleAction({this.schedule});
}

class SetWeeksForCurrentScheduleAction extends Action {
  final Map<String, List<Week>> weeks;

  SetWeeksForCurrentScheduleAction({this.weeks});
}

class SetSignatureMap extends Action {
  final Map<String, String> signatures;

  SetSignatureMap({this.signatures});
}

class AddSignature extends Action {
  final Map<String, String> signatures;

  AddSignature({this.signatures});
}
