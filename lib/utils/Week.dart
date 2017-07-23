import 'Day.dart';

class Week {
  List<Day> days;
  int number;

  Week({this.days, this.number});

  Map<String, dynamic> serialize() {
    return {
      "days": days.map((day) => day.serialize()).toList(growable: false),
      "number": number
    };
  }

  static Week deserialize(Map<String, dynamic> week) {
    return new Week(
        days: week["days"].map((day) => Day.deserialize(day)).toList(),
        number: week["number"]
    );
  }
}