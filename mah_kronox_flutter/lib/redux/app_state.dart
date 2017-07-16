import 'package:flutter/material.dart';

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
      primaryColor: Colors.indigo,
      accentColor: Colors.pinkAccent);

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